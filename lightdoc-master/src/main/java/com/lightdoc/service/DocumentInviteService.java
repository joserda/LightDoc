package com.lightdoc.service;

import com.lightdoc.dto.InviteDTO;
import com.lightdoc.dto.InviteDetailDTO;
import com.lightdoc.dto.MemberDTO;

import java.util.List;

/**
 * 文档邀请服务接口
 */
public interface DocumentInviteService {
    
    /**
     * 邀请用户加入文档
     *
     * @param documentId 文档ID
     * @param dto 邀请信息
     * @param inviterId 邀请者ID
     * @return 是否成功
     */
    boolean inviteUser(Long documentId, InviteDTO dto, Long inviterId);
    
    /**
     * 接受邀请
     *
     * @param documentId 文档ID
     * @param userId 被邀请用户ID
     * @return 是否成功
     */
    boolean acceptInvite(Long documentId, Long userId);
    
    /**
     * 拒绝邀请
     *
     * @param documentId 文档ID
     * @param userId 被邀请用户ID
     * @return 是否成功
     */
    boolean rejectInvite(Long documentId, Long userId);
    
    /**
     * 获取文档成员列表
     *
     * @param documentId 文档ID
     * @return 成员列表
     */
    List<MemberDTO> getDocumentMembers(Long documentId);
    
    /**
     * 移除成员
     *
     * @param documentId 文档ID
     * @param operatorId 操作者ID
     * @param userId 要移除的用户ID
     * @return 是否成功
     */
    boolean removeMember(Long documentId, Long operatorId, Long userId);
    
    /**
     * 修改成员权限
     *
     * @param documentId 文档ID
     * @param operatorId 操作者ID
     * @param userId 用户ID
     * @param permissionLevel 新的权限级别
     * @return 是否成功
     */
    boolean updateMemberPermission(Long documentId, Long operatorId, Long userId, Integer permissionLevel);
    
    /**
     * 获取文档的待处理邀请列表
     *
     * @param documentId 文档ID
     * @return 邀请列表
     */
    List<InviteDetailDTO> getDocumentInvites(Long documentId);
    
    /**
     * 获取用户的待处理邀请列表
     *
     * @param userId 用户ID
     * @return 邀请列表
     */
    List<InviteDetailDTO> getUserInvites(Long userId);
    
    /**
     * 检查用户是否已经是文档成员
     *
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否是成员
     */
    boolean isDocumentMember(Long documentId, Long userId);
    
    /**
     * 检查是否有待处理的邀请
     *
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否有待处理邀请
     */
    boolean hasPendingInvite(Long documentId, Long userId);
}