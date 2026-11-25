/**
 * 领域层（Domain）—— 业务规则的唯一归属地。
 *
 * <p>只负责：聚合根与值对象、状态机的合法跳转白名单、数据归属判定、仓储接口定义。
 * <p>禁止：依赖 Spring Web、Redis、MyBatis 等技术实现；仓储只声明接口，实现放在 infrastructure。
 *
 * <ul>
 *   <li>{@code model} —— 聚合根（User、Diary、Report、Tag、Announcement）与值对象（DiaryStatus）</li>
 *   <li>{@code repository} —— 仓储接口，领域层只认接口不认实现</li>
 *   <li>{@code statemachine} —— DiaryStateMachine / ReportStateMachine，非法跳转在此抛出领域异常</li>
 *   <li>{@code service} —— 跨聚合的领域服务，如归属校验、标签关联</li>
 * </ul>
 *
 * <p>设计意图：把「谁能在什么状态下做什么」这条最容易被写散的业务规则收敛到一处，
 * 后端校验才可能做到前后一致、可测试、可答辩解释。
 */
package com.daytrace.domain;
