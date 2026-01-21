package com.lightdoc.service;

import com.lightdoc.dto.DocumentVersionDTO;

import java.util.List;

public interface DocumentVersionService {

    List<DocumentVersionDTO> listVersions(Long documentId, Long userId);

    DocumentVersionDTO createVersion(Long documentId, Long userId, String yjsState, String description);

    String getSnapshot(Long documentId, Integer versionNumber, Long userId);

    boolean rollbackToVersion(Long documentId, Integer versionNumber, Long userId);
}
