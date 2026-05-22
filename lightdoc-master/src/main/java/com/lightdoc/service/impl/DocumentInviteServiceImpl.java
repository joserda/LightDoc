package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.dto.InviteDTO;
import com.lightdoc.dto.InviteDetailDTO;
import com.lightdoc.dto.MemberDTO;
import com.lightdoc.entity.Document;
import com.lightdoc.entity.DocumentPermission;
import com.lightdoc.entity.DocumentOperationLog;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.DocumentMapper;
import com.lightdoc.mapper.DocumentPermissionMapper;
import com.lightdoc.mapper.DocumentOperationLogMapper;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.DocumentInviteService;
import com.lightdoc.utils.NotificationUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 文档邀请服务实现类
 */
@Slf4j
@Service
public class DocumentInviteServiceImpl implements DocumentInviteService {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Autowired
    private DocumentMapper documentMapper;
    
    @Autowired
    private DocumentPermissionMapper documentPermissionMapper;
    
    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private DocumentOperationLogMapper documentOperationLogMapper;

    @Autowired
    private NotificationUtil notificationUtil;
    
    private static final String INVITE_KEY_PREFIX = "doc:invite:";
    private static final String USER_INVITE_KEY_PREFIX = "user:invites:";
    private static final long INVITE_TTL_DAYS = 7;
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean inviteUser(Long documentId, InviteDTO dto, Long inviterId) {
        // 1. 检查邀请者权限
        Integer inviterPermission = getUserPermission(documentId, inviterId);
        if (inviterPermission == null || inviterPermission < 2) {
            log.warn("用户 {} 无权限邀请用户加入文档 {}", inviterId, documentId);
            return false;
        }
        
        // 2. 权限级别限制
        if (dto.getPermissionLevel() > inviterPermission) {
            log.warn("用户 {} 尝试设置高于自己权限级别的邀请", inviterId);
            return false;
        }
        
        // 3. 检查是否已经是成员
        if (isDocumentMember(documentId, dto.getUserId())) {
            log.warn("用户 {} 已经是文档 {} 的成员", dto.getUserId(), documentId);
            return false;
        }
        
        // 4. 检查是否已有待处理邀请
        if (hasPendingInvite(documentId, dto.getUserId())) {
            log.warn("用户 {} 对文档 {} 已有待处理的邀请", dto.getUserId(), documentId);
            return false;
        }
        
        // 5. 获取文档信息
        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            log.warn("文档 {} 不存在", documentId);
            return false;
        }
        
        // 6. 获取邀请者信息
        User inviter = userMapper.selectById(inviterId);
        if (inviter == null) {
            log.warn("邀请者 {} 不存在", inviterId);
            return false;
        }
        
        // 7. 在Redis中创建邀请记录
        String inviteKey = INVITE_KEY_PREFIX + documentId + ":" + dto.getUserId();
        Map<String, Object> inviteData = new HashMap<>();
        inviteData.put("documentId", documentId);
        inviteData.put("userId", dto.getUserId());
        inviteData.put("inviterId", inviterId);
        inviteData.put("permissionLevel", dto.getPermissionLevel());
        inviteData.put("inviteTime", System.currentTimeMillis());
        inviteData.put("status", "pending");
        inviteData.put("documentTitle", document.getTitle());
        inviteData.put("inviterNickname", inviter.getNickname());
        redisTemplate.opsForHash().putAll(inviteKey, inviteData);
        redisTemplate.expire(inviteKey, INVITE_TTL_DAYS, TimeUnit.DAYS);
        
        // 8. 添加到用户的待处理邀请列表
        String userInviteKey = USER_INVITE_KEY_PREFIX + dto.getUserId();
        redisTemplate.opsForSet().add(userInviteKey, documentId + ":" + dto.getUserId());
        redisTemplate.expire(userInviteKey, INVITE_TTL_DAYS, TimeUnit.DAYS);
        
        // 9. 记录操作日志
        DocumentOperationLog operationLog = new DocumentOperationLog();
        operationLog.setDocumentId(documentId);
        operationLog.setUserId(inviterId);
        operationLog.setOperationType("invite");
        operationLog.setOperationDetail("邀请用户 " + dto.getUserId() + " 加入文档");
        operationLog.setOperationTime(LocalDateTime.now());
        documentOperationLogMapper.insert(operationLog);
        
        // 10. 发送邀请通知
        try {
            String inviterName = inviter.getNickname() != null ? inviter.getNickname() : inviter.getUsername();
            notificationUtil.sendDocumentInvite(
                dto.getUserId(),
                documentId,
                "文档邀请",
                inviterName + " 邀请您加入文档《" + document.getTitle() + "》"
            );
            log.info("已向用户 {} 发送文档邀请通知", dto.getUserId());
        } catch (Exception e) {
            log.error("发送邀请通知失败", e);
            // 通知发送失败不影响邀请流程
        }
        
        log.info("用户 {} 邀请用户 {} 加入文档 {}，权限级别: {}", inviterId, dto.getUserId(), documentId, dto.getPermissionLevel());
        return true;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean acceptInvite(Long documentId, Long userId) {
        String inviteKey = INVITE_KEY_PREFIX + documentId + ":" + userId;
        
        // 1. 检查邀请是否存在
        if (!redisTemplate.hasKey(inviteKey)) {
            log.warn("邀请不存在或已过期: documentId={}, userId={}", documentId, userId);
            return false;
        }
        
        // 2. 读取邀请信息
        Map<Object, Object> inviteData = redisTemplate.opsForHash().entries(inviteKey);
        Long inviterId = Long.valueOf(inviteData.get("inviterId").toString());
        Integer permissionLevel = Integer.valueOf(inviteData.get("permissionLevel").toString());
        Long inviteTime = Long.valueOf(inviteData.get("inviteTime").toString());
        
        // 3. 在document_permissions表中创建正式权限记录
        DocumentPermission permission = new DocumentPermission();
        permission.setDocumentId(documentId);
        permission.setUserId(userId);
        permission.setPermissionType("write");  // 设置权限类型
        permission.setPermissionLevel(permissionLevel);
        permission.setGrantedBy(inviterId);     // 设置授权者为邀请者
        permission.setGrantedAt(LocalDateTime.now());  // 设置授权时间为当前时间
        permission.setInviterId(inviterId);
        permission.setInviteTime(java.time.Instant.ofEpochMilli(inviteTime).atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        permission.setInviteStatus("accepted");
        permission.setCreatedAt(LocalDateTime.now());
        documentPermissionMapper.insert(permission);
        
        // 4. 删除Redis中的邀请记录
        redisTemplate.delete(inviteKey);
        
        // 5. 从用户的待处理邀请列表中移除
        String userInviteKey = USER_INVITE_KEY_PREFIX + userId;
        redisTemplate.opsForSet().remove(userInviteKey, documentId + ":" + userId);
        
        // 6. 记录操作日志
        DocumentOperationLog operationLog = new DocumentOperationLog();
        operationLog.setDocumentId(documentId);
        operationLog.setUserId(userId);
        operationLog.setOperationType("accept_invite");
        operationLog.setOperationDetail("接受邀请");
        operationLog.setOperationTime(LocalDateTime.now());
        documentOperationLogMapper.insert(operationLog);
        
        log.info("用户 {} 接受了文档 {} 的邀请", userId, documentId);
        return true;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean rejectInvite(Long documentId, Long userId) {
        String inviteKey = INVITE_KEY_PREFIX + documentId + ":" + userId;
        
        // 1. 检查邀请是否存在
        if (!redisTemplate.hasKey(inviteKey)) {
            log.warn("邀请不存在或已过期: documentId={}, userId={}", documentId, userId);
            return false;
        }
        
        // 2. 删除Redis中的邀请记录
        redisTemplate.delete(inviteKey);
        
        // 3. 从用户的待处理邀请列表中移除
        String userInviteKey = USER_INVITE_KEY_PREFIX + userId;
        redisTemplate.opsForSet().remove(userInviteKey, documentId + ":" + userId);
        
        // 4. 记录操作日志
        DocumentOperationLog operationLog = new DocumentOperationLog();
        operationLog.setDocumentId(documentId);
        operationLog.setUserId(userId);
        operationLog.setOperationType("reject_invite");
        operationLog.setOperationDetail("拒绝邀请");
        operationLog.setOperationTime(LocalDateTime.now());
        documentOperationLogMapper.insert(operationLog);
        
        log.info("用户 {} 拒绝了文档 {} 的邀请", userId, documentId);
        return true;
    }
    
    @Override
    public List<MemberDTO> getDocumentMembers(Long documentId) {
        List<DocumentPermission> permissions = documentPermissionMapper.selectList(
                new LambdaQueryWrapper<DocumentPermission>()
                        .eq(DocumentPermission::getDocumentId, documentId)
        );

        List<MemberDTO> members = permissions.stream().map(permission -> {
            MemberDTO dto = new MemberDTO();
            dto.setUserId(permission.getUserId());
            dto.setPermissionLevel(permission.getPermissionLevel());
            dto.setInviteTime(permission.getInviteTime());
            dto.setJoinedAt(permission.getCreatedAt());

            User user = userMapper.selectById(permission.getUserId());
            if (user != null) {
                dto.setUsername(user.getUsername());
                dto.setNickname(user.getNickname());
                dto.setAvatar(user.getAvatar());
                dto.setEmail(user.getEmail());
            }

            if (permission.getInviterId() != null) {
                User inviter = userMapper.selectById(permission.getInviterId());
                if (inviter != null) {
                    dto.setInviterNickname(inviter.getNickname());
                }
            }

            return dto;
        }).collect(Collectors.toList());

        Document document = documentMapper.selectById(documentId);
        if (document != null && document.getOwnerId() != null) {
            Long ownerId = document.getOwnerId();
            boolean ownerExists = permissions.stream()
                    .anyMatch(p -> ownerId.equals(p.getUserId()));
            if (!ownerExists) {
                MemberDTO ownerDto = new MemberDTO();
                ownerDto.setUserId(ownerId);
                ownerDto.setPermissionLevel(3);
                ownerDto.setInviteTime(document.getCreatedAt());
                ownerDto.setJoinedAt(document.getCreatedAt());

                User owner = userMapper.selectById(ownerId);
                if (owner != null) {
                    ownerDto.setUsername(owner.getUsername());
                    ownerDto.setNickname(owner.getNickname());
                    ownerDto.setAvatar(owner.getAvatar());
                    ownerDto.setEmail(owner.getEmail());
                }

                members.add(ownerDto);
            }
        }

        return members;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean removeMember(Long documentId, Long operatorId, Long userId) {
        // 1. 检查操作者是否为文档所有者
        Integer operatorPermission = getUserPermission(documentId, operatorId);
        if (operatorPermission == null) {
            log.warn("用户 {} 不是文档 {} 的成员", operatorId, documentId);
            return false;
        }
        
        // 2. 检查是否是所有者（所有者权限级别为3）
        if (operatorPermission != 3) {
            log.warn("用户 {} 无权限移除文档 {} 的成员", operatorId, documentId);
            return false;
        }
        
        // 3. 不能移除自己
        if (operatorId.equals(userId)) {
            log.warn("不能移除自己");
            return false;
        }
        
        // 4. 删除权限记录
        int result = documentPermissionMapper.delete(
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId)
                .eq(DocumentPermission::getUserId, userId)
        );
        
        // 5. 记录操作日志
        DocumentOperationLog operationLog = new DocumentOperationLog();
        operationLog.setDocumentId(documentId);
        operationLog.setUserId(operatorId);
        operationLog.setOperationType("remove_member");
        operationLog.setOperationDetail("移除成员 " + userId);
        operationLog.setOperationTime(LocalDateTime.now());
        documentOperationLogMapper.insert(operationLog);
        
        log.info("用户 {} 移除了文档 {} 的成员 {}", operatorId, documentId, userId);
        return result > 0;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateMemberPermission(Long documentId, Long operatorId, Long userId, Integer permissionLevel) {
        // 1. 检查操作者是否为文档所有者
        Integer operatorPermission = getUserPermission(documentId, operatorId);
        if (operatorPermission == null || operatorPermission != 3) {
            log.warn("用户 {} 无权限修改文档 {} 的成员权限", operatorId, documentId);
            return false;
        }
        
        // 2. 不能修改自己的权限
        if (operatorId.equals(userId)) {
            log.warn("不能修改自己的权限");
            return false;
        }
        
        // 3. 更新权限级别
        DocumentPermission permission = new DocumentPermission();
        permission.setPermissionLevel(permissionLevel);
        int result = documentPermissionMapper.update(permission,
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId)
                .eq(DocumentPermission::getUserId, userId)
        );
        
        // 4. 记录操作日志
        DocumentOperationLog operationLog = new DocumentOperationLog();
        operationLog.setDocumentId(documentId);
        operationLog.setUserId(operatorId);
        operationLog.setOperationType("update_permission");
        operationLog.setOperationDetail("修改用户 " + userId + " 的权限级别为 " + permissionLevel);
        operationLog.setOperationTime(LocalDateTime.now());
        documentOperationLogMapper.insert(operationLog);
        
        log.info("用户 {} 修改了文档 {} 的成员 {} 的权限级别为 {}", operatorId, documentId, userId, permissionLevel);
        return result > 0;
    }
    
    @Override
    public List<InviteDetailDTO> getDocumentInvites(Long documentId) {
        Set<String> keys = redisTemplate.keys(INVITE_KEY_PREFIX + documentId + ":*");
        List<InviteDetailDTO> invites = new ArrayList<>();
        
        for (String key : keys) {
            Map<Object, Object> data = redisTemplate.opsForHash().entries(key);
            InviteDetailDTO dto = new InviteDetailDTO();
            dto.setDocumentId(Long.valueOf(data.get("documentId").toString()));
            dto.setUserId(Long.valueOf(data.get("userId").toString()));
            dto.setDocumentTitle((String) data.get("documentTitle"));
            dto.setInviterId(Long.valueOf(data.get("inviterId").toString()));
            dto.setInviterNickname((String) data.get("inviterNickname"));
            dto.setPermissionLevel(Integer.valueOf(data.get("permissionLevel").toString()));
            dto.setInviteTime(Long.valueOf(data.get("inviteTime").toString()));
            dto.setStatus((String) data.get("status"));
            invites.add(dto);
        }
        
        return invites;
    }
    
    @Override
    public List<InviteDetailDTO> getUserInvites(Long userId) {
        String userInviteKey = USER_INVITE_KEY_PREFIX + userId;
        Set<Object> inviteKeys = redisTemplate.opsForSet().members(userInviteKey);
        List<InviteDetailDTO> invites = new ArrayList<>();
        
        for (Object key : inviteKeys) {
            String inviteKey = INVITE_KEY_PREFIX + key.toString();
            Map<Object, Object> data = redisTemplate.opsForHash().entries(inviteKey);
            InviteDetailDTO dto = new InviteDetailDTO();
            dto.setDocumentId(Long.valueOf(data.get("documentId").toString()));
            dto.setUserId(Long.valueOf(data.get("userId").toString()));
            dto.setDocumentTitle((String) data.get("documentTitle"));
            dto.setInviterId(Long.valueOf(data.get("inviterId").toString()));
            dto.setInviterNickname((String) data.get("inviterNickname"));
            dto.setPermissionLevel(Integer.valueOf(data.get("permissionLevel").toString()));
            dto.setInviteTime(Long.valueOf(data.get("inviteTime").toString()));
            dto.setStatus((String) data.get("status"));
            invites.add(dto);
        }
        
        return invites;
    }
    
    @Override
    public boolean isDocumentMember(Long documentId, Long userId) {
        Long count = documentPermissionMapper.selectCount(
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId)
                .eq(DocumentPermission::getUserId, userId)
        );
        return count > 0;
    }
    
    @Override
    public boolean hasPendingInvite(Long documentId, Long userId) {
        String inviteKey = INVITE_KEY_PREFIX + documentId + ":" + userId;
        return redisTemplate.hasKey(inviteKey);
    }
    
    /**
     * 获取用户在文档中的权限级别
     */
    private Integer getUserPermission(Long documentId, Long userId) {
        // 首先检查是否是文档所有者
        Document document = documentMapper.selectById(documentId);
        if (document != null && document.getOwnerId().equals(userId)) {
            return 3;
        }
        
        // 检查权限表中的记录
        DocumentPermission permission = documentPermissionMapper.selectOne(
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId)
                .eq(DocumentPermission::getUserId, userId)
        );
        return permission != null ? permission.getPermissionLevel() : null;
    }
}
