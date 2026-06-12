package com.qiu.imagesearch.tools;

import jakarta.annotation.Resource;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class ImageSearchToolTest {

    @Resource
    private ImageSearchTool imageSearchTool;

    @Test
    void searchImage() {
        String result = imageSearchTool.searchImage("computer");
        System.out.println("Search result: " + result);
        Assertions.assertNotNull(result);
    }

    @Test
    void searchMediumImages() {
        var images = imageSearchTool.searchMediumImages("nature");
        System.out.println("Found " + images.size() + " images");
        images.forEach(System.out::println);
        Assertions.assertNotNull(images);
    }
}
