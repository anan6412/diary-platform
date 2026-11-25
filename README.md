# 日迹 Diary Platform

> 面向个人记录与轻社区分享的日记平台，支持 AI 辅助整理、公开内容审核与举报治理。

个人日记 + 轻社区分享。用户记录日常并决定是否公开；公开内容经审核员审核后进入社区流，违规内容可被举报并能被及时下架；平台借助国产大模型为日记自动生成摘要、情绪标签与标签推荐。

## 目标用户

- **个人记录者**：需要一个纯粹的、数据归属于自己的日记本
- **愿意分享的写作者**：希望把部分日记公开，但不想自己暴露在无审核的公开流里
- **平台运营方**：需要内容审核、举报治理与内容运营能力

## 团队与分工

| 姓名 | 学号 | 负责模块 | 主要文件/目录 | 贡献比例 |
|---|---|---|---|---|
| 待填 | 待填 | 认证与 RBAC、日记与状态机、AI 与 WebSocket、架构与文档 | `domain/`、`application/`、`interfaces/controller/{Auth,User,Role,Diary,Review,Ai}*`、`infrastructure/{security,ai,websocket}` | 70% |
| 待填 | 待填 | 公告模块、标签模块、单元测试与接口测试 | `AnnouncementController`、`TagController`、`src/test/java/**` | 30% |

## 技术栈

| 层 | 选型 | 版本 |
|---|---|---|
| JDK | Temurin | 21 |
| 后端 | Spring Boot | 3.2.12 |
| 安全 | Spring Security | 6.2.x |
| 令牌 | jjwt | 0.12.6 |
| ORM | MyBatis-Plus | 3.5.7 |
| 数据库 | MySQL | 8.0 |
| 缓存 | Redis | 7.x |
| 接口文档 | SpringDoc OpenAPI | 2.3.0 |
| 测试 | JUnit 5 + Mockito + JaCoCo | 0.8.11 |
| 前端 | Vue 3 + Vite + Element Plus | — |
| AI | DeepSeek `deepseek-chat`（OpenAI 兼容） | — |

## 系统架构

（待补充：系统架构图、后端分层图、鉴权时序图）

## RBAC 设计

（待补充：角色列表、角色×权限矩阵、校验实现位置）

## 数据库设计

（待补充：ER 图 + 13 张表用途说明）

## 功能清单

（待补充：按角色列出已实现功能）

## 接口文档

启动后访问 `http://localhost:8080/swagger-ui.html`

## 本地运行

（待补充：15 分钟内可复现的完整步骤）

## 演示账号

（待补充）

## 测试

（待补充：运行命令、用例清单、覆盖率报告）

## 附加分申请

（待补充：每一项做了什么、代码位置、如何验证）

## 第三方代码声明

本项目未使用任何现成后台脚手架（RuoYi / JeecgBoot / Pig 等）作为基础，认证、权限与业务代码均为自行实现。

第三方依赖：Spring Boot、Spring Security、MyBatis-Plus、jjwt、SpringDoc、Hutool（如有）等，均为通过 Maven 引入的开源库。

## AI 使用说明

核心 prompt 见 [docs/prompts.md](docs/prompts.md)。

## 文档

- [项目计划与框架设计](docs/项目计划.md)
- [AI 使用说明与核心 prompt](docs/prompts.md)
