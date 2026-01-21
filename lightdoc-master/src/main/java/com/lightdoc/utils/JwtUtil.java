package com.lightdoc.utils;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT工具类
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Slf4j
@Component
public class JwtUtil {
    
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private Long expiration;
    
    private static final String USER_ID_CLAIM = "userId";
    
    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secret);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    /**
     * 生成token（包含用户名和用户ID）
     * 
     * @param username 用户名
     * @param id 用户ID
     * @return token字符串
     */
    public String generateToken(String username, Long id) {
        return generateToken(username, id, null);
    }
    
    /**
     * 生成token（包含用户名和额外claims）
     * 
     * @param username 用户名
     * @param claims 额外claims
     * @return token字符串
     */
    public String generateToken(String username, Map<String, Object> claims) {
        return generateToken(username, null, claims);
    }
    
    /**
     * 生成token（包含用户名、用户ID和额外claims）
     * 
     * @param username 用户名
     * @param userId 用户ID
     * @param claims 额外claims
     * @return token字符串
     */
    public String generateToken(String username, Long userId, Map<String, Object> claims) {
        Date expirationDate = new Date(System.currentTimeMillis() + expiration);
        
        Map<String, Object> allClaims = new HashMap<>();
        if (claims != null) {
            allClaims.putAll(claims);
        }
        if (userId != null) {
            allClaims.put(USER_ID_CLAIM, userId);
        }
        
        JwtBuilder builder = Jwts.builder()
                .subject(username)
                .expiration(expirationDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256);
        
        if (!allClaims.isEmpty()) {
            builder.addClaims(allClaims);
        }
        
        return builder.compact();
    }
    
    /**
     * 从token获取用户名
     * 
     * @param token token字符串
     * @return 用户名
     */
    public String extractUsername(String token) {
        try {
            return extractClaims(token).getSubject();
        } catch (Exception e) {
            log.error("解析token失败: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 从token获取用户ID
     * 
     * @param token token字符串
     * @return 用户ID
     */
    public Long extractUserId(String token) {
        try {
            Claims claims = extractClaims(token);
            Object userId = claims.get(USER_ID_CLAIM);
            if (userId instanceof Integer) {
                return ((Integer) userId).longValue();
            } else if (userId instanceof Long) {
                return (Long) userId;
            }
            return null;
        } catch (Exception e) {
            log.error("从token提取用户ID失败: {}", e.getMessage());
            return null;
        }
    }
    
    /**
     * 获取token的claims
     * 
     * @param token token字符串
     * @return claims
     */
    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
    
    /**
     * 验证token是否有效
     * 
     * @param token token字符串
     * @return 是否有效
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.error("Token已过期: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.error("不支持的Token: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            log.error("无效的Token格式: {}", e.getMessage());
        } catch (SignatureException e) {
            log.error("Token签名错误: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.error("Token参数错误: {}", e.getMessage());
        }
        return false;
    }
    
    /**
     * 检查token是否过期
     * 
     * @param token token字符串
     * @return 是否过期
     */
    public boolean isTokenExpired(String token) {
        try {
            Claims claims = extractClaims(token);
            Date expiration = claims.getExpiration();
            return expiration.before(new Date());
        } catch (Exception e) {
            return true;
        }
    }
    
    /**
     * 从token获取用户名（兼容旧方法名）
     * 
     * @param token token字符串
     * @return 用户名
     * @deprecated 使用 {@link #extractUsername(String)} 代替
     */
    @Deprecated
    public String getUsernameFromToken(String token) {
        return extractUsername(token);
    }
    
    /**
     * 获取token的claims（兼容旧方法名）
     * 
     * @param token token字符串
     * @return claims
     * @deprecated 使用 {@link #extractClaims(String)} 代替
     */
    @Deprecated
    public Claims getClaimsFromToken(String token) {
        return extractClaims(token);
    }

    /**
     * 从请求中获取用户ID
     *
     * @param request HTTP请求
     * @return 用户ID
     */
    public Long getUserIdFromRequest(HttpServletRequest request) {
        String token = request.getHeader("Authorization");

        if (token == null || !token.startsWith("Bearer ")) {
            return null;
        }

        token = token.substring(7);

        try {
            if (!validateToken(token)) {
                return null;
            }

            return extractUserId(token);
        } catch (Exception e) {
            log.error("从token提取用户信息时发生异常: {}", e.getMessage(), e);
            return null;
        }
    }
}