package com.lightdoc.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 邀请用户加入文档DTO
 */
@Data
public class InviteDTO {
    
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    
    @NotNull(message = "权限级别不能为空")
    private Integer permissionLevel;
}