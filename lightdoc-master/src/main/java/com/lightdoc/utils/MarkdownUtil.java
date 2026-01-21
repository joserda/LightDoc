package com.lightdoc.utils;

import com.vladsch.flexmark.ext.tables.TablesExtension;
import com.vladsch.flexmark.html.HtmlRenderer;
import com.vladsch.flexmark.parser.Parser;
import com.vladsch.flexmark.util.ast.Document;
import com.vladsch.flexmark.util.data.MutableDataSet;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Slf4j
@Component
public class MarkdownUtil {

    private final Parser parser;
    private final HtmlRenderer htmlRenderer;

    public MarkdownUtil() {
        MutableDataSet options = new MutableDataSet();
        options.set(Parser.EXTENSIONS, Arrays.asList(TablesExtension.create()));
        options.set(HtmlRenderer.SOFT_BREAK, "<br/>");

        this.parser = Parser.builder(options).build();
        this.htmlRenderer = HtmlRenderer.builder(options).build();
    }

    public String markdownToHtml(String markdown) {
        if (markdown == null || markdown.trim().isEmpty()) {
            return "";
        }

        try {
            Document document = parser.parse(markdown);
            return htmlRenderer.render(document);
        } catch (Exception e) {
            log.error("Markdown转换HTML失败: {}", e.getMessage());
            throw new RuntimeException("Markdown转换失败", e);
        }
    }

    public String extractText(String markdown) {
        if (markdown == null || markdown.trim().isEmpty()) {
            return "";
        }

        try {
            String html = markdownToHtml(markdown);
            return html.replaceAll("<[^>]*>", " ").replaceAll("\\s+", " ").trim();
        } catch (Exception e) {
            log.error("提取Markdown文本失败: {}", e.getMessage());
            return markdown;
        }
    }

    public int countWords(String markdown) {
        if (markdown == null || markdown.trim().isEmpty()) {
            return 0;
        }

        String text = extractText(markdown);
        if (text.isEmpty()) {
            return 0;
        }

        return text.split("\\s+").length;
    }
}