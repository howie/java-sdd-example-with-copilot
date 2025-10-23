package com.thsr.booking.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("台灣高鐵訂票系統 API")
                .description("台灣高鐵訂票系統的 RESTful API 文件")
                .version("v0.0.1")
                .license(new License()
                    .name("Apache 2.0")
                    .url("http://springdoc.org")));
    }
}