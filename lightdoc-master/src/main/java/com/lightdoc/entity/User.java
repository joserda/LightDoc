package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户实体类
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
@TableName("users")
public class User {
    
    /**
     * 用户ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户名
     */
    @TableField("username")
    private String username;
    
    /**
     * 邮箱
     */
    @TableField("email")
    private String email;
    
    /**
     * 密码
     */
    @TableField("password")
    private String password;
    
    /**
     * 昵称
     */
    @TableField("nickname")
    private String nickname;
    
    /**
     * 状态（0-禁用，1-启用）
     */
    @TableField("status")
    private Integer status;
    
    /**
     * 角色（user-普通用户，admin-管理员）
     */
    @TableField("role")
    private String role;
    
    /**
     * 头像URL
     */
    @TableField("avatar")
    private String avatar;
    
    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}