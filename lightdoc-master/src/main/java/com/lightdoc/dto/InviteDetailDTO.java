package com.lightdoc.dto;

import lombok.Data;

/**
 * 邀请详情DTO
 */
@Data
public class InviteDetailDTO {
    
    private Long documentId;
    private Long userId;
    private String documentTitle;
    private Long inviterId;
    private String inviterNickname;
    private Integer permissionLevel;
    private Long inviteTime;
    private String status; // pending, accepted, rejected
}