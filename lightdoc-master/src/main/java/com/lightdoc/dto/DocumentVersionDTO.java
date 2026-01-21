package com.lightdoc.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DocumentVersionDTO {

    private Integer versionNumber;

    private String versionType;

    private Long snapshotSize;

    private String changeDescription;

    private Long createdBy;

    private String creatorNickname;

    private LocalDateTime createdAt;
}
