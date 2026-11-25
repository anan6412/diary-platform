/**
 * 基础设施层（Infrastructure）—— 所有技术细节集中在这里。
 *
 * <p>只负责：实现领域层声明的仓储接口、封装安全/缓存/实时通信/外部 API 调用、提供 Spring 配置。
 * <p>这是唯一允许出现 Redis、MyBatis、HTTP Client 等框架代码的层。
 *
 * <ul>
 *   <li>{@code persistence} —— PO（对应表）、MyBatis-Plus Mapper、RepositoryImpl</li>
 *   <li>{@code security} —— JwtTokenProvider、JwtAuthenticationFilter、PermissionEvaluator</li>
 *   <li>{@code cache} —— Token 黑名单、日记详情缓存、接口限流</li>
 *   <li>{@code websocket} —— 站内通知推送与握手鉴权</li>
 *   <li>{@code ai} —— 国产大模型客户端抽象与 DeepSeek 实现</li>
 *   <li>{@code config} —— SecurityConfig、MybatisPlusConfig、RedisConfig、OpenApiConfig</li>
 * </ul>
 */
package com.daytrace.infrastructure;
