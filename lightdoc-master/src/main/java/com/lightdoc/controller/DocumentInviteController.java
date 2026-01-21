package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.dto.InviteDTO;
import com.lightdoc.dto.InviteDetailDTO;
import com.lightdoc.dto.MemberDTO;
import com.lightdoc.service.CollaborationService;
import com.lightdoc.service.DocumentInviteService;
import com.lightdoc.utils.SecurityUtils;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 文档邀请控制器
 */
@Slf4j
@RestController
@RequestMapping("/documents")
public class DocumentInviteController {
    
    @Autowired
    private DocumentInviteService documentInviteService;
    
    @Autowired
    private CollaborationService collaborationService;
    
    /**
     * 邀请用户加入文档
     */
    @PostMapping("/{documentId}/invite")
    public Result<Boolean> inviteUser(@PathVariable Long documentId, @Valid @RequestBody InviteDTO dto) {
        log.info("收到邀请请求: documentId={}, dto={}", documentId, dto);
        
        Long inviterId = SecurityUtils.getCurrentUserId();
        log.info("获取到的邀请者ID: {}", inviterId);
        
        if (inviterId == null) {
            log.warn("邀请者ID为空，返回401");
            return Result.error(401, "未授权");
        }
        
        boolean success = documentInviteService.inviteUser(documentId, dto, inviterId);
        log.info("邀请结果: {}", success);
        
        if (success) {
            return Result.success(true);
        } else {
            return Result.error(400, "邀请失败");
        }
    }
    
    /**
     * 接受邀请
     */
    @PutMapping("/{documentId}/invites/accept")
    public Result<Boolean> acceptInvite(@PathVariable Long documentId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error(401, "未授权");
        }
        
        boolean success = documentInviteService.acceptInvite(documentId, userId);
        if (success) {
            return Result.success(true);
        } else {
            return Result.error(400, "接受邀请失败");
        }
    }
    
    /**
     * 拒绝邀请
     */
    @PutMapping("/{documentId}/invites/reject")
    public Result<Boolean> rejectInvite(@PathVariable Long documentId) {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error(401, "未授权");
        }
        
        boolean success = documentInviteService.rejectInvite(documentId, userId);
        if (success) {
            return Result.success(true);
        } else {
            return Result.error(400, "拒绝邀请失败");
        }
    }
    
    /**
     * 获取文档成员列表
     */
    @GetMapping("/{documentId}/members")
    public Result<List<MemberDTO>> getDocumentMembers(@PathVariable Long documentId) {
        List<MemberDTO> members = documentInviteService.getDocumentMembers(documentId);
        return Result.success(members);
    }

    /**
     * 获取文档当前在线用户ID列表
     */
    @GetMapping("/{documentId}/online-users")
    public Result<java.util.Set<Long>> getDocumentOnlineUsers(@PathVariable Long documentId) {
        java.util.Set<Long> onlineUsers = collaborationService.getOnlineUsers(documentId);
        return Result.success(onlineUsers);
    }
    
    /**
     * 移除成员
     */
    @DeleteMapping("/{documentId}/members/{userId}")
    public Result<Boolean> removeMember(@PathVariable Long documentId, @PathVariable Long userId) {
        Long operatorId = SecurityUtils.getCurrentUserId();
        if (operatorId == null) {
            return Result.error(401, "未授权");
        }
        
        boolean success = documentInviteService.removeMember(documentId, operatorId, userId);
        if (success) {
            return Result.success(true);
        } else {
            return Result.error(400, "移除成员失败");
        }
    }
    
    /**
     * 修改成员权限
     */
    @PutMapping("/{documentId}/members/{userId}/permission")
    public Result<Boolean> updateMemberPermission(
            @PathVariable Long documentId,
            @PathVariable Long userId,
            @RequestParam Integer permissionLevel) {
        Long operatorId = SecurityUtils.getCurrentUserId();
        if (operatorId == null) {
            return Result.error(401, "未授权");
        }
        
        boolean success = documentInviteService.updateMemberPermission(documentId, operatorId, userId, permissionLevel);
        if (success) {
            return Result.success(true);
        } else {
            return Result.error(400, "权限修改失败");
        }
    }
    
    /**
     * 获取文档的待处理邀请列表
     */
    @GetMapping("/{documentId}/invites")
    public Result<List<InviteDetailDTO>> getDocumentInvites(@PathVariable Long documentId) {
        List<InviteDetailDTO> invites = documentInviteService.getDocumentInvites(documentId);
        return Result.success(invites);
    }
    
    /**
     * 获取当前用户的待处理邀请列表
     */
    @GetMapping("/user/invites")
    public Result<List<InviteDetailDTO>> getUserInvites() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error(401, "未授权");
        }
        
        List<InviteDetailDTO> invites = documentInviteService.getUserInvites(userId);
        return Result.success(invites);
    }
}
