package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lightdoc.dto.KnowledgeBaseDTO;
import com.lightdoc.dto.KnowledgeBaseQueryDTO;
import com.lightdoc.entity.KnowledgeBase;
import com.lightdoc.entity.KnowledgeBasePermission;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.KnowledgeBaseMapper;
import com.lightdoc.mapper.KnowledgeBasePermissionMapper;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.KnowledgeBaseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 知识库服务实现类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Slf4j
@Service
public class KnowledgeBaseServiceImpl implements KnowledgeBaseService {
    
    private final KnowledgeBaseMapper knowledgeBaseMapper;
    private final KnowledgeBasePermissionMapper knowledgeBasePermissionMapper;
    private final UserMapper userMapper;
    
    public KnowledgeBaseServiceImpl(KnowledgeBaseMapper knowledgeBaseMapper,
                                   KnowledgeBasePermissionMapper knowledgeBasePermissionMapper,
                                   UserMapper userMapper) {
        this.knowledgeBaseMapper = knowledgeBaseMapper;
        this.knowledgeBasePermissionMapper = knowledgeBasePermissionMapper;
        this.userMapper = userMapper;
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public KnowledgeBaseDTO createKnowledgeBase(KnowledgeBaseDTO knowledgeBaseDTO, Long userId) {
        log.info("用户 {} 创建知识库: {}", userId, knowledgeBaseDTO.getName());
        
        try {
            // 创建知识库记录
            KnowledgeBase knowledgeBase = new KnowledgeBase();
            knowledgeBase.setName(knowledgeBaseDTO.getName());
            knowledgeBase.setDescription(knowledgeBaseDTO.getDescription());
            knowledgeBase.setOwnerId(userId);
            knowledgeBase.setParentId(knowledgeBaseDTO.getParentId());
            knowledgeBase.setStatus(knowledgeBaseDTO.getStatus() != null ? knowledgeBaseDTO.getStatus() : 0); // 默认正常状态
            knowledgeBase.setPermissionLevel(knowledgeBaseDTO.getPermissionLevel() != null ? knowledgeBaseDTO.getPermissionLevel() : 0); // 默认私有
            knowledgeBase.setIsPublic(knowledgeBaseDTO.getIsPublic() != null ? knowledgeBaseDTO.getIsPublic() : false);
            knowledgeBase.setDocCount(0); // 初始文档数量为0
            
            knowledgeBaseMapper.insert(knowledgeBase);
            
            // 为创建者分配管理权限
            KnowledgeBasePermission permission = new KnowledgeBasePermission();
            permission.setKnowledgeBaseId(knowledgeBase.getId());
            permission.setUserId(userId);
            permission.setPermissionType("manage");
            permission.setPermissionLevel(3); // 管理权限
            permission.setGrantedBy(userId);
            permission.setGrantedAt(java.time.LocalDateTime.now()); // 设置授权时间
            knowledgeBasePermissionMapper.insert(permission);
            
            log.info("知识库创建成功，ID: {}", knowledgeBase.getId());
            return convertToDTO(knowledgeBase);
            
        } catch (Exception e) {
            log.error("创建知识库失败: {}", e.getMessage(), e);
            throw new RuntimeException("创建知识库失败: " + e.getMessage());
        }
    }
    
    @Override
    public KnowledgeBaseDTO getKnowledgeBaseDetail(Long knowledgeBaseId, Long userId) {
        log.info("查询知识库详情，知识库ID: {}, 用户ID: {}", knowledgeBaseId, userId);
        
        KnowledgeBase knowledgeBase = knowledgeBaseMapper.selectById(knowledgeBaseId);
        if (knowledgeBase == null) {
            throw new RuntimeException("知识库不存在");
        }
        
        if (!hasPermission(knowledgeBaseId, userId, 0)) {
            throw new RuntimeException("没有权限访问该知识库");
        }
        
        return convertToDTO(knowledgeBase);
    }
    
    @Override
    public IPage<KnowledgeBaseDTO> queryKnowledgeBases(KnowledgeBaseQueryDTO queryDTO, Long userId) {
        log.info("查询知识库列表，用户ID: {}, 查询条件: {}", userId, queryDTO);
        
        Page<KnowledgeBase> page = new Page<>(queryDTO.getPage(), queryDTO.getSize());
        
        LambdaQueryWrapper<KnowledgeBase> wrapper = new LambdaQueryWrapper<KnowledgeBase>()
                .eq(queryDTO.getParentId() != null, KnowledgeBase::getParentId, queryDTO.getParentId())
                .eq(queryDTO.getOwnerId() != null, KnowledgeBase::getOwnerId, queryDTO.getOwnerId())
                .eq(queryDTO.getStatus() != null, KnowledgeBase::getStatus, queryDTO.getStatus())
                .like(StringUtils.hasText(queryDTO.getName()), KnowledgeBase::getName, queryDTO.getName())
                .eq(queryDTO.getIsPublic() != null, KnowledgeBase::getIsPublic, queryDTO.getIsPublic())
                .and(w -> w.eq(KnowledgeBase::getOwnerId, userId)
                        .or()
                        .eq(KnowledgeBase::getIsPublic, true)
                        .or()
                        .exists("SELECT 1 FROM knowledge_base_permissions p WHERE p.knowledge_base_id = knowledge_bases.id AND p.user_id = " + userId + " AND p.permission_level >= 1"));
        
        IPage<KnowledgeBase> knowledgeBasePage = knowledgeBaseMapper.selectPage(page, wrapper);
        
        return knowledgeBasePage.convert(this::convertToDTO);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public KnowledgeBaseDTO updateKnowledgeBase(Long knowledgeBaseId, KnowledgeBaseDTO knowledgeBaseDTO, Long userId) {
        log.info("更新知识库，知识库ID: {}, 用户ID: {}", knowledgeBaseId, userId);
        
        KnowledgeBase knowledgeBase = knowledgeBaseMapper.selectById(knowledgeBaseId);
        if (knowledgeBase == null) {
            throw new RuntimeException("知识库不存在");
        }
        
        if (!hasPermission(knowledgeBaseId, userId, 2)) {
            throw new RuntimeException("没有权限修改该知识库");
        }
        
        // 检查父知识库是否有效（防止循环引用）
        if (knowledgeBaseDTO.getParentId() != null) {
            validateParentId(knowledgeBaseId, knowledgeBaseDTO.getParentId());
        }
        
        if (StringUtils.hasText(knowledgeBaseDTO.getName())) {
            knowledgeBase.setName(knowledgeBaseDTO.getName());
        }
        if (StringUtils.hasText(knowledgeBaseDTO.getDescription())) {
            knowledgeBase.setDescription(knowledgeBaseDTO.getDescription());
        }
        if (knowledgeBaseDTO.getParentId() != null) {
            knowledgeBase.setParentId(knowledgeBaseDTO.getParentId());
        }
        if (knowledgeBaseDTO.getStatus() != null) {
            knowledgeBase.setStatus(knowledgeBaseDTO.getStatus());
        }
        if (knowledgeBaseDTO.getPermissionLevel() != null) {
            knowledgeBase.setPermissionLevel(knowledgeBaseDTO.getPermissionLevel());
        }
        if (knowledgeBaseDTO.getIsPublic() != null) {
            knowledgeBase.setIsPublic(knowledgeBaseDTO.getIsPublic());
        }
        
        knowledgeBaseMapper.updateById(knowledgeBase);
        
        log.info("知识库更新成功，知识库ID: {}", knowledgeBaseId);
        return convertToDTO(knowledgeBase);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteKnowledgeBase(Long knowledgeBaseId, Long userId) {
        log.info("删除知识库，知识库ID: {}, 用户ID: {}", knowledgeBaseId, userId);
        
        KnowledgeBase knowledgeBase = knowledgeBaseMapper.selectById(knowledgeBaseId);
        if (knowledgeBase == null) {
            throw new RuntimeException("知识库不存在");
        }
        
        if (!hasPermission(knowledgeBaseId, userId, 2)) {
            throw new RuntimeException("没有权限删除该知识库");
        }
        
        // 检查是否有子知识库，如果有需要先删除子知识库
        List<KnowledgeBase> children = knowledgeBaseMapper.selectList(
            new LambdaQueryWrapper<KnowledgeBase>().eq(KnowledgeBase::getParentId, knowledgeBaseId));
        if (!children.isEmpty()) {
            throw new RuntimeException("请先删除所有子知识库");
        }
        
        // 删除知识库权限
        knowledgeBasePermissionMapper.delete(
            new LambdaQueryWrapper<KnowledgeBasePermission>()
                .eq(KnowledgeBasePermission::getKnowledgeBaseId, knowledgeBaseId));
        
        // 删除知识库
        knowledgeBaseMapper.deleteById(knowledgeBaseId);
        
        log.info("知识库删除成功，知识库ID: {}", knowledgeBaseId);
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public KnowledgeBaseDTO moveKnowledgeBase(Long knowledgeBaseId, Long parentId, Long userId) {
        log.info("移动知识库，知识库ID: {}, 新父知识库ID: {}, 用户ID: {}", knowledgeBaseId, parentId, userId);
        
        KnowledgeBase knowledgeBase = knowledgeBaseMapper.selectById(knowledgeBaseId);
        if (knowledgeBase == null) {
            throw new RuntimeException("知识库不存在");
        }
        
        if (!hasPermission(knowledgeBaseId, userId, 2)) {
            throw new RuntimeException("没有权限移动该知识库");
        }
        
        // 验证新的父知识库ID
        if (parentId != null) {
            KnowledgeBase parent = knowledgeBaseMapper.selectById(parentId);
            if (parent == null) {
                throw new RuntimeException("父知识库不存在");
            }
            
            validateParentId(knowledgeBaseId, parentId);
        }
        
        knowledgeBase.setParentId(parentId);
        knowledgeBaseMapper.updateById(knowledgeBase);
        
        log.info("知识库移动成功，知识库ID: {}", knowledgeBaseId);
        return convertToDTO(knowledgeBase);
    }
    
    @Override
    public boolean hasPermission(Long knowledgeBaseId, Long userId, int requiredPermission) {
        if (userId == null) {
            return false;
        }
        
        KnowledgeBase knowledgeBase = knowledgeBaseMapper.selectById(knowledgeBaseId);
        if (knowledgeBase == null) {
            return false;
        }
        
        // 检查是否为知识库所有者
        if (knowledgeBase.getOwnerId().equals(userId)) {
            return true;
        }
        
        // 检查公开权限
        if (knowledgeBase.getIsPublic()) {
            if (requiredPermission == 0) {
                return true;
            }
            return knowledgeBase.getPermissionLevel() != null && knowledgeBase.getPermissionLevel() >= requiredPermission;
        }
        
        // 检查特定权限
        KnowledgeBasePermission permission = knowledgeBasePermissionMapper.selectOne(
            new LambdaQueryWrapper<KnowledgeBasePermission>()
                .eq(KnowledgeBasePermission::getKnowledgeBaseId, knowledgeBaseId)
                .eq(KnowledgeBasePermission::getUserId, userId));
        
        if (permission != null) {
            return permission.getPermissionLevel() >= requiredPermission;
        }
        
        return false;
    }
    
    /**
     * 验证父知识库ID，防止循环引用
     */
    private void validateParentId(Long knowledgeBaseId, Long parentId) {
        if (knowledgeBaseId.equals(parentId)) {
            throw new RuntimeException("父知识库不能是自己");
        }
        
        // 检查是否形成循环引用
        KnowledgeBase current = knowledgeBaseMapper.selectById(parentId);
        while (current != null && current.getParentId() != null) {
            if (current.getParentId().equals(knowledgeBaseId)) {
                throw new RuntimeException("不能形成循环引用");
            }
            current = knowledgeBaseMapper.selectById(current.getParentId());
        }
    }
    
    private KnowledgeBaseDTO convertToDTO(KnowledgeBase knowledgeBase) {
        KnowledgeBaseDTO dto = new KnowledgeBaseDTO();
        BeanUtils.copyProperties(knowledgeBase, dto);
        
        if (knowledgeBase.getOwnerId() != null) {
            User user = userMapper.selectById(knowledgeBase.getOwnerId());
            if (user != null) {
                dto.setOwnerNickname(user.getNickname());
            }
        }
        
        return dto;
    }
}