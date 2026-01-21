package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.UserMapper;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserMapper userMapper;

    public UserDetailsServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, username)
                .or()
                .eq(User::getEmail, username));

        if (user == null) {
            throw new UsernameNotFoundException("用户不存在");
        }

        // 检查用户状态
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new UsernameNotFoundException("账户已被禁用");
        }

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities(getUserAuthorities(user.getRole()))
                .build();
    }

    private String[] getUserAuthorities(String role) {
        if ("admin".equals(role)) {
            return new String[]{"ROLE_ADMIN", "ROLE_USER"};
        } else {
            return new String[]{"ROLE_USER"};
        }
    }
}
