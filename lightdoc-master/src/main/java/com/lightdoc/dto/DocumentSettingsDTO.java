package com.lightdoc.dto;

import lombok.Data;

@Data
public class DocumentSettingsDTO {

    private Boolean versioningEnabled;

    private Integer maxVersionCount;

    private Boolean autosaveEnabled;

    private Integer autosaveIntervalSeconds;
}

