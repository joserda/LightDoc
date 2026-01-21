package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.dto.LoginDTO;
import com.lightdoc.dto.RegisterDTO;
import com.lightdoc.entity.User;
import com.lightdoc.service.UserService;
import com.lightdoc.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserService userService;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil, UserService userService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userService = userService;
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginDTO loginDTO) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginDTO.getUsername(), loginDTO.getPassword())
            );

            User user = userService.findByUsernameOrEmail(loginDTO.getUsername());
            if (user == null) {
                return Result.error("用户不存在");
            }

            if (!userService.checkPassword(loginDTO.getPassword(), user.getPassword())) {
                return Result.error("密码错误");
            }

            // 检查用户状态
            if (user.getStatus() != null && user.getStatus() == 0) {
                return Result.error("账户已被禁用");
            }

            String token = jwtUtil.generateToken(user.getUsername(), user.getId());

            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getId());
            userData.put("username", user.getUsername());
            userData.put("email", user.getEmail());
            userData.put("nickname", user.getNickname());
            userData.put("avatar", user.getAvatar());
            userData.put("status", user.getStatus());
            userData.put("role", user.getRole());
            data.put("user", userData);

            log.info("用户: " + user.getUsername() + " 登录成功");

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("登录失败：" + e.getMessage());
        }
    }

    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody RegisterDTO registerDTO) {
        if (userService.existsByUsername(registerDTO.getUsername())) {
            return Result.error("用户名已存在");
        }

        if (userService.existsByEmail(registerDTO.getEmail())) {
            return Result.error("邮箱已存在");
        }

        User user = userService.register(registerDTO);

        String token = jwtUtil.generateToken(user.getUsername(), user.getId());

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        
        Map<String, Object> userData = new HashMap<>();
        userData.put("id", user.getId());
        userData.put("username", user.getUsername());
        userData.put("email", user.getEmail());
        userData.put("nickname", user.getNickname());
        userData.put("avatar", user.getAvatar());
        userData.put("status", user.getStatus());
        userData.put("role", user.getRole());
        data.put("user", userData);

        return Result.success(data);
    }
}
