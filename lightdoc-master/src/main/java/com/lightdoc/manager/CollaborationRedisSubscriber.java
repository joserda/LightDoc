package com.lightdoc.manager;

import com.alibaba.fastjson2.JSON;
import com.lightdoc.dto.CollaborationBroadcastMessageDTO;
import com.lightdoc.dto.CollaborationMessageDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Slf4j
@Component
@RequiredArgsConstructor
public class CollaborationRedisSubscriber implements MessageListener {

    private final CollaborationSessionManager sessionManager;

    @Override
    public void onMessage(Message message, byte[] pattern) {
        log.info("=============《 redis channel 处理消息中 》=============");
        try {
            String body = new String(message.getBody(), StandardCharsets.UTF_8);
            CollaborationBroadcastMessageDTO broadcast = JSON.parseObject(body, CollaborationBroadcastMessageDTO.class);
            if (broadcast == null || broadcast.getDocumentId() == null) {
                return;
            }
            if (broadcast.isBinary()) {
                byte[] data = Base64.getDecoder().decode(broadcast.getPayload());
                sessionManager.broadcastBinaryToDocument(broadcast.getDocumentId(), data, broadcast.getExcludeSessionId());
            } else {
                CollaborationMessageDTO dto = JSON.parseObject(broadcast.getPayload(), CollaborationMessageDTO.class);
                if (dto == null) {
                    return;
                }
                sessionManager.broadcastToDocument(broadcast.getDocumentId(), dto, broadcast.getExcludeSessionId());
            }
        } catch (Exception e) {
            log.error("处理Redis协同消息失败: {}", e.getMessage(), e);
        }
    }
}

