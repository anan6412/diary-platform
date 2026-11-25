package com.daytrace;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 日迹日记平台 - 应用入口。
 *
 * <p>分层约定（DDD 四层）：
 * <ul>
 *   <li>{@code interfaces} —— 接口层：Controller / DTO / 全局异常。只做参数接收与返回，不含业务判断。</li>
 *   <li>{@code application} —— 应用层：用例编排、事务边界、事件发布。</li>
 *   <li>{@code domain} —— 领域层：聚合根、值对象、状态机、领域服务、仓储接口。</li>
 *   <li>{@code infrastructure} —— 基础设施层：持久化、安全、缓存、WebSocket、外部 AI 调用。</li>
 * </ul>
 * 依赖方向严格单向：interfaces → application → domain ← infrastructure。
 */
@SpringBootApplication
@MapperScan("com.daytrace.infrastructure.persistence.mapper")
public class DiaryApplication {

    public static void main(String[] args) {
        SpringApplication.run(DiaryApplication.class, args);
    }
}
