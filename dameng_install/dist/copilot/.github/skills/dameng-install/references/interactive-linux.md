# Linux 交互安装与初始化

示例使用 `dmdba:dinstall`、`/opt/dmdbms` 和 `/opt/dmdata`。替换为确认清单中的路径、实例名和端口，不把示例作为固定环境。所有写入先核对目标及已有内容。

## 1. 准备目录、账号、限制和介质

root 创建缺失的专用用户/组和本次新目录，设置软件/数据/归档/备份为专用用户可访问，安装临时目录可用 `0700`。创建和传输系统配置后核验属主，限额配置不能由普通运维用户可写。

核实 ISO 未被挂载到其他路径、目标挂载点没有已有内容，再只读挂载：

```bash
mount -o loop,ro <已确认ISO绝对路径> <安装介质挂载点>
```

从可见 root 终端切换：

```bash
su - dmdba
```

检查 `id`、`ulimit -n`、`ulimit -u`，以及数据和临时目录可写。不要把 `sudo -iu` 包装成复杂单次安装命令。

用户登录 shell 可有较短 `TMOUT`；本次会话按环境允许临时延长，例如 `export TMOUT=3600`。每次 `su -` 或厂商脚本重新加载 `.bashrc` 后再次检查，不改全系统超时策略。

## 2. 软件安装

由专用用户启动：

```bash
DM_INSTALL_TMPDIR=<确认的临时目录> <挂载点>/DMInstall.bin -i
```

按安装器实际提示逐项处理：语言、许可证路径/是否提供Key、时区、安装类型、安装目录、摘要、执行确认。只有在输出相应提示后才提交答案。

数字菜单不跨版本猜序号，选择服务器时检查安装小结确实为“服务器”。某终端桥接只发送CR时输入可能未被消费或拼接；收到“非法选项”时先读屏幕/输出及输入状态，再按终端工具支持方式使用LF换行。不要连续盲发数字。

以“安装完成/安装结束”和实际文件为证，不仅看 shell 提示出现。安装器要求 root 后处理时，退出安装用户，核对当前提示身份，读取要执行的厂商脚本再执行它。例如：

```bash
/opt/dmdbms/script/root/root_installer.sh
```

此脚本可能移动 `dm_svc.conf`、创建/启动辅助服务，应核查实际脚本，不对其他版本承诺相同动作。

安装后检查 `dmserver`、`dminit`、`disql`、所需驱动和 `ldd` 缺失项。安装器可能只写 `DM_HOME` 和库路径而漏掉PATH；补齐 `.bash_profile`，保留原有有效配置，然后重新登录或 `source` 验证。新增环境可用：

```bash
export DM_HOME="<安装目录>"
export PATH="$DM_HOME/bin:$PATH"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$DM_HOME/bin"
```

## 3. 选择建库入口

先运行 `dminit help`，核对确认值是否能由本版工具设置。未经确认不能把不支持的参数强行写入命令。确认数据目录为空且 `AUTO_OVERWRITE=0`，并检查可用日志空间。

### 无参数交互引导

```bash
dminit
```

跟随提示输入：数据根目录、数据库名、端口、页/簇大小、权限模式、时区、大小写、字符集、加密/页校验、镜像路径以及该版本其余选项；SYSDBA和SYSAUDITOR密码使用隐藏提示并确认两次。

不要预设所有版本有相同顺序。`USE_DB_NAME=1` 常表示路径追加数据库名，应核实避免生成错误目录。未要求加密、镜像、专用权限模式时保留确认过的默认值。资源自动调优基准先说明并确认，生成后核查实际池大小。

重点：无参数引导可能没有 `INSTANCE_NAME` 或 `LOG_SIZE` 等输入项。实例名可按实际参数修改，但若用户要求特定日志大小，必须在生成库之前选择能够表达该要求的入口。曾验证的2026-02-12介质无参数引导生成2个各4096MB日志，不会因先前失败命令写过 `LOG_SIZE=512` 就继承该值。

### 显式参数路径

当必须设置引导未覆盖的字段时，使用厂商支持的显式 `KEY=value`、配置工具或初始化控制文件。带参数模式可能直接拒绝缺少必填口令，而不是继续提示；检查结果，不能宣布建库成功。

若采用shell变量收取隐藏密码，命令历史应只含变量名，并明确变量展开后凭据可能短暂出现在进程参数中。按环境的密钥/审计要求选择可接受路径，不能声称该方案完全不暴露argv。示例先逐条执行隐藏读取：

```bash
read -r -s -p 'SYSDBA password: ' DM_INIT_SYSDBA_PWD
read -r -s -p 'SYSAUDITOR password: ' DM_INIT_AUDITOR_PWD
```

然后在已有授权和环境的凭据要求允许此入口时，执行已审阅的非敏感参数及变量；不因采用常规安装入口而重复请求已获得的安装授权：

```bash
dminit PATH=<数据根目录> DB_NAME=<库名> INSTANCE_NAME=<实例名> PORT_NUM=<端口> PAGE_SIZE=<KB> EXTENT_SIZE=<页数> CASE_SENSITIVE=<0或1> CHARSET=<0或1> LOG_SIZE=<MB> TIME_ZONE=<时区> AUTO_OVERWRITE=0 SYSDBA_PWD="$DM_INIT_SYSDBA_PWD" SYSAUDITOR_PWD="$DM_INIT_AUDITOR_PWD"
```

这些尖括号是说明占位符，不能原样交给shell。初始化结束后清理变量。若版本对密码内引号等字符还有工具层规则，先查同版手册，不能只用shell引用解决所有解析层。

无论哪种入口，保存“create dm database success”证据，查看本次建库日志、配置路径和实际重做日志大小。密码不保存到日志/skill中。

## 4. 首次启动配置

先备份本次生成的 `dm.ini`，精确修改确认的普通/静态字段，保留其余生成内容。不能把另一库dm.ini整份覆盖到新库，尤其是控制文件、数据路径、主备/集群、审计和内存项。

按实际文件和 `PARA_TYPE` 处理兼容模式、整数运算、排序、日期、资源和审计文件策略。只有已明确确认归档时创建 `dmarch.ini` 并设置 `ARCH_INI=1`。候选模板：

```ini
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL
ARCH_DEST = <归档目录>
ARCH_FILE_SIZE = <单文件MB>
ARCH_SPACE_LIMIT = <总上限MB>
```

`ENABLE_AUDIT` 是由数据库审计过程控制的状态，不将它作为普通dm.ini字段添加。`PWD_POLICY` 等参数也可能不出现在dm.ini；通过数据库过程和系统目录核查持久化。

配置文件传输后确认 `dmdba:dinstall` 或实际专用属主，以及 `640` 等适当权限。systemd服务定义应为root管理。

## 5. 服务与数据库内配置

返回可见root shell，按厂商脚本为新库注册服务。例如确认路径后：

```bash
/opt/dmdbms/script/root/dm_service_installer.sh -t dmserver -dm_ini <dm.ini绝对路径> -p <实例服务后缀>
```

读取生成的服务名/定义/限制，再启动该服务，核对自启和实际进程用户。若脚本已设置自启，不重复改无关服务。

切换到专用用户交互登录，密码直接在提示输入：

```bash
disql -L SYSDBA@127.0.0.1:<确认端口>
```

`-L` 限制失败登录重试；`-S` 静默模式会隐藏部分提示，交互操作默认不用它。

已确认强密码参数后，通过对应权限账号设置，例如：

```sql
CALL SP_SET_PARA_VALUE(1, 'PWD_MIN_LEN', 12);
CALL SP_SET_PARA_VALUE(1, 'PWD_POLICY', 31);
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME 90;
```

这三个数字是示例，不是自动执行项。SYSDBA和SYSAUDITOR口令都必须验证；修改DEFAULT不替代内置用户的实际资源限制检查。

已确认开启审计时以SYSAUDITOR或具有审计权限的账号执行：

```sql
CALL SP_SET_ENABLE_AUDIT(2);
```

确认0/1/2与用户选择一致；细粒度规则单独授权。若审计限额不支持且用户选择暂不开启，保持0，记录待办，不先启用再请求确认。

## 6. 网络与收尾

获授权后只为明确来源/端口添加firewalld或该站点使用的规则，检查活动zone。firewalld可分别添加运行时和永久规则，避免无必要的全局reload；记录执行前状态与回退方案。以实际允许节点验证TCP。

配置若需重启，验证窗口和当前连接，退出disql，按工具风险策略执行，随后重新登录和核验。完成后退出到已识别的运维shell。安装临时目录不等于运行时TEMP表空间；清理/卸载ISO仅在确认无安装进程、无后续依赖并获相应范围授权时处理。
