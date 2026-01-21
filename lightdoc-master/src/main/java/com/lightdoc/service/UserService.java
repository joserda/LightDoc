package com.lightdoc.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.dto.RegisterDTO;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.UserMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
    }

    public User findByUsernameOrEmail(String usernameOrEmail) {
        return userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, usernameOrEmail)
                .or()
                .eq(User::getEmail, usernameOrEmail));
    }

    public boolean existsByUsername(String username) {
        return userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, username)) > 0;
    }

    public boolean existsByEmail(String email) {
        return userMapper.selectCount(new LambdaQueryWrapper<User>()
                .eq(User::getEmail, email)) > 0;
    }

    public User register(RegisterDTO registerDTO) {
        User user = new User();
        user.setUsername(registerDTO.getUsername());
        user.setEmail(registerDTO.getEmail());
        user.setNickname(registerDTO.getNickname());
        user.setPassword(passwordEncoder.encode(registerDTO.getPassword()));
        user.setStatus(1); // 默认启用状态
        user.setRole("user"); // 默认普通用户角色
        userMapper.insert(user);
        return user;
    }

    public boolean checkPassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    /**
     * 搜索用户（按用户名或邮箱）
     *
     * @param keyword 搜索关键词
     * @param excludeIds 排除的用户ID列表
     * @return 用户列表
     */
    public List<User> searchUsers(String keyword, List<Long> excludeIds) {
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        
        // 搜索条件：用户名或邮箱包含关键词
        if (keyword != null && !keyword.trim().isEmpty()) {
            queryWrapper.and(wrapper -> wrapper
                    .like(User::getUsername, keyword.trim())
                    .or()
                    .like(User::getEmail, keyword.trim())
            );
        }
        
        // 排除指定用户
        if (excludeIds != null && !excludeIds.isEmpty()) {
            queryWrapper.notIn(User::getId, excludeIds);
        }
        
        // 排除已禁用用户（状态为0），未设置状态或为1的用户视为正常
        queryWrapper.and(wrapper -> wrapper.isNull(User::getStatus).or().ne(User::getStatus, 0));
        
        // 限制返回数量
        queryWrapper.last("LIMIT 20");
        
        return userMapper.selectList(queryWrapper);
    }
}
