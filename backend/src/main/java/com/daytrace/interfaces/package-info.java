/**
 * 接口层（Interfaces）。
 *
 * <p>只负责：接收 HTTP 请求、参数校验（Bean Validation）、调用应用层、把结果装配成 DTO 返回。
 * <p>禁止：业务规则判断、直接访问 Mapper、把数据库实体直接返回给前端。
 *
 * <ul>
 *   <li>{@code controller} —— REST 接口，遵循 Restful 风格</li>
 *   <li>{@code dto} —— 请求/响应对象，按模块分子包；响应 DTO 中不存在 password 字段</li>
 *   <li>{@code assembler} —— DTO 与领域对象的转换，避免 Controller 里写转换逻辑</li>
 *   <li>{@code advice} —— 全局异常处理与统一返回体包装，保证不把堆栈返回前端</li>
 * </ul>
 */
package com.daytrace.interfaces;
