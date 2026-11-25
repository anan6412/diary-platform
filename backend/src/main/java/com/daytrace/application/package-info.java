/**
 * 应用层（Application）。
 *
 * <p>只负责：用例编排（一个方法 = 一个业务用例）、事务边界、领域事件发布。
 * <p>禁止：写 SQL、出现 HttpServletRequest 等 Web 类型、包含可复用的业务规则（应下沉到 domain）。
 *
 * <ul>
 *   <li>{@code service} —— AppService，例如 AuthAppService、DiaryAppService</li>
 *   <li>{@code command} —— 写操作入参（CreateDiaryCommand）</li>
 *   <li>{@code query} —— 读操作入参（DiaryPageQuery）</li>
 *   <li>{@code event} —— 领域事件的发布与监听，例如审核结果触发 WebSocket 推送</li>
 * </ul>
 */
package com.daytrace.application;
