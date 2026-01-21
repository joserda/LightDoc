package com.lightdoc.service;

import com.lightdoc.dto.DocumentSettingsDTO;

public interface DocumentSettingsService {

    DocumentSettingsDTO getSettings(Long documentId, Long userId);

    DocumentSettingsDTO updateSettings(Long documentId, Long userId, DocumentSettingsDTO settingsDTO);
}

