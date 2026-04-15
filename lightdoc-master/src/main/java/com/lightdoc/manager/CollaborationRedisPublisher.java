package com.lightdoc.manager;

import com.alibaba.fastjson2.JSON;
import com.lightdoc.dto.CollaborationBroadcastMessageDTO;
import com.lightdoc.dto.CollaborationMessageDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Slf4j
@Component
@RequiredArgsConstructor
public class CollaborationRedisPublisher {

    private static final String CHANNEL_PREFIX = "collab:doc:broadcast:";

    private final StringRedisTemplate stringRedisTemplate;

    @Value("${collaboration.redis.channel-shards:8}")
    private int channelShards;

    public void publishText(Long documentId, CollaborationMessageDTO message, String excludeSessionId) {
        if (documentId == null || message == null) {
            return;
        }
        try {
            CollaborationBroadcastMessageDTO broadcast = new CollaborationBroadcastMessageDTO();
            broadcast.setDocumentId(documentId);
            broadcast.setExcludeSessionId(excludeSessionId);
            broadcast.setBinary(false);
            broadcast.setPayload(JSON.toJSONString(message));
            String json = JSON.toJSONString(broadcast);
            stringRedisTemplate.convertAndSend(resolveChannel(documentId), json);
        } catch (Exception e) {
            log.error("发布协同文本消息到Redis失败: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }

    public void publishBinary(Long documentId, byte[] data, String excludeSessionId) {
        if (documentId == null || data == null || data.length == 0) {
            return;
        }
        try {
            String encoded = Base64.getEncoder().encodeToString(data);
            CollaborationBroadcastMessageDTO broadcast = new CollaborationBroadcastMessageDTO();
            broadcast.setDocumentId(documentId);
            broadcast.setExcludeSessionId(excludeSessionId);
            broadcast.setBinary(true);
            broadcast.setPayload(encoded);
            String json = JSON.toJSONString(broadcast);
            stringRedisTemplate.convertAndSend(resolveChannel(documentId), json);
        } catch (Exception e) {
            log.error("发布协同二进制消息到Redis失败: documentId={}, length={}, error={}", documentId, data.length, e.getMessage(), e);
        }
    }

    private String resolveChannel(Long documentId) {
        int shards = channelShards > 0 ? channelShards : 1;
        int shard = Math.floorMod(documentId, shards);
        return CHANNEL_PREFIX + shard;
    }
}
