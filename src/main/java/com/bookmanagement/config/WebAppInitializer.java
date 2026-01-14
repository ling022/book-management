package com.bookmanagement.config;

import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.multipart.support.MultipartFilter;
import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

import javax.servlet.Filter;
import javax.servlet.ServletRegistration;

public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return new Class<?>[] { MyBatisConfig.class };
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[] { WebConfig.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }

    @Override
    protected String getServletName() {
        return "book-dispatcher";
    }
    // 配置过滤器
    @Override
    protected Filter[] getServletFilters() {
        CharacterEncodingFilter encodingFilter = new CharacterEncodingFilter();
        encodingFilter.setEncoding("UTF-8");
        encodingFilter.setForceEncoding(true);

        // ====== 新增：添加MultipartFilter ======
        MultipartFilter multipartFilter = new MultipartFilter();
        multipartFilter.setMultipartResolverBeanName("multipartResolver");

        return new Filter[] { encodingFilter, multipartFilter };
    }

    // ====== 新增：配置Servlet初始化参数 ======
    @Override
    protected void customizeRegistration(ServletRegistration.Dynamic registration) {
        // 启用multipart配置
        registration.setMultipartConfig(
                new javax.servlet.MultipartConfigElement(
                        "",          // 临时存储路径（空表示使用系统默认）
                        10 * 1024 * 1024,  // 最大文件大小 10MB
                        50 * 1024 * 1024,  // 最大请求大小 50MB
                        0           // 文件大小阈值，0表示所有文件都写入磁盘
                )
        );
    }
    }