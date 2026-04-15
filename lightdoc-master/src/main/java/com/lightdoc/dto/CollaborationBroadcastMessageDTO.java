package com.lightdoc.dto;

import lombok.Data;

@Data
public class CollaborationBroadcastMessageDTO {

    private Long documentId;

    private String excludeSessionId;

    private boolean binary;

    private String payload;
}

