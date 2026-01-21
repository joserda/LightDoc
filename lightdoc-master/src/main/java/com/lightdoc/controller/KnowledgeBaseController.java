package com.lightdoc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lightdoc.common.Result;
import com.lightdoc.dto.KnowledgeBaseDTO;
import com.lightdoc.dto.KnowledgeBaseQueryDTO;
import com.lightdoc.service.KnowledgeBaseService;
import com.lightdoc.utils.SecurityUtils;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 知识库管理控制器
 *
 * @author lightdoc
 * @since 2025-11-28
 */
@Slf4j
@RestController
@RequestMapping("/knowledge-bases")
public class KnowledgeBaseController {

    private final KnowledgeBaseService knowledgeBaseService;

    public KnowledgeBaseController(KnowledgeBaseService knowledgeBaseService) {
        this.knowledgeBaseService = knowledgeBaseService;
    }

    /**
     * 创建知识库
     *
     * @param knowledgeBaseDTO 知识库信息
     * @return 创建结果
     */
    @PostMapping
    public Result<KnowledgeBaseDTO> createKnowledgeBase(@Valid @RequestBody KnowledgeBaseDTO knowledgeBaseDTO) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            KnowledgeBaseDTO result = knowledgeBaseService.createKnowledgeBase(knowledgeBaseDTO, userId);
            return Result.success(result);
        } catch (Exception e) {
            log.error("创建知识库失败: {}", e.getMessage(), e);
            return Result.error("创建知识库失败: " + e.getMessage());
        }
    }

    /**
     * 获取知识库详情
     *
     * @param knowledgeBaseId 知识库ID
     * @return 知识库详情
     */
    @GetMapping("/{knowledgeBaseId}")
    public Result<KnowledgeBaseDTO> getKnowledgeBase(@PathVariable("knowledgeBaseId") Long knowledgeBaseId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            KnowledgeBaseDTO knowledgeBaseDTO = knowledgeBaseService.getKnowledgeBaseDetail(knowledgeBaseId, userId);
            return Result.success(knowledgeBaseDTO);
        } catch (Exception e) {
            log.error("获取知识库详情失败: {}", e.getMessage(), e);
            return Result.error("获取知识库详情失败: " + e.getMessage());
        }
    }

    /**
     * 分页查询知识库列表
     *
     * @param queryDTO 查询条件
     * @return 知识库列表
     */
    @GetMapping
    public Result<IPage<KnowledgeBaseDTO>> queryKnowledgeBases(@Valid KnowledgeBaseQueryDTO queryDTO) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            IPage<KnowledgeBaseDTO> page = knowledgeBaseService.queryKnowledgeBases(queryDTO, userId);
            return Result.success(page);
        } catch (Exception e) {
            log.error("查询知识库列表失败: {}", e.getMessage(), e);
            return Result.error("查询知识库列表失败: " + e.getMessage());
        }
    }

    /**
     * 更新知识库信息
     *
     * @param knowledgeBaseId   知识库ID
     * @param knowledgeBaseDTO 知识库信息
     * @return 更新结果
     */
    @PutMapping("/{knowledgeBaseId}")
    public Result<KnowledgeBaseDTO> updateKnowledgeBase(
            @PathVariable("knowledgeBaseId") Long knowledgeBaseId,
            @Valid @RequestBody KnowledgeBaseDTO knowledgeBaseDTO) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            KnowledgeBaseDTO result = knowledgeBaseService.updateKnowledgeBase(knowledgeBaseId, knowledgeBaseDTO, userId);
            return Result.success(result);
        } catch (Exception e) {
            log.error("更新知识库失败: {}", e.getMessage(), e);
            return Result.error("更新知识库失败: " + e.getMessage());
        }
    }

    /**
     * 删除知识库
     *
     * @param knowledgeBaseId 知识库ID
     * @return 删除结果
     */
    @DeleteMapping("/{knowledgeBaseId}")
    public Result<Void> deleteKnowledgeBase(@PathVariable("knowledgeBaseId") Long knowledgeBaseId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            knowledgeBaseService.deleteKnowledgeBase(knowledgeBaseId, userId);
            return Result.success();
        } catch (Exception e) {
            log.error("删除知识库失败: {}", e.getMessage(), e);
            return Result.error("删除知识库失败: " + e.getMessage());
        }
    }

    /**
     * 移动知识库（更改父知识库）
     *
     * @param knowledgeBaseId 知识库ID
     * @param parentId        新的父知识库ID
     * @return 移动结果
     */
    @PutMapping("/{knowledgeBaseId}/move")
    public Result<KnowledgeBaseDTO> moveKnowledgeBase(
            @PathVariable("knowledgeBaseId") Long knowledgeBaseId,
            @RequestParam Long parentId) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未认证");
            }

            KnowledgeBaseDTO result = knowledgeBaseService.moveKnowledgeBase(knowledgeBaseId, parentId, userId);
            return Result.success(result);
        } catch (Exception e) {
            log.error("移动知识库失败: {}", e.getMessage(), e);
            return Result.error("移动知识库失败: " + e.getMessage());
        }
    }
}