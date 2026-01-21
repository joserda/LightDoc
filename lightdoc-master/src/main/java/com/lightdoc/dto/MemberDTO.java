package com.lightdoc.dto;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档成员DTO
 */
@Data
public class MemberDTO {
    
    private Long userId;
    private String username;
    private String nickname;
    private String avatar;
    private String email;
    private Integer permissionLevel;
    private LocalDateTime inviteTime;
    private LocalDateTime joinedAt;
    private String inviterNickname;
}
