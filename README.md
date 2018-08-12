# Rails Template

## 描述

主要用于 Rails 项目的快速搭建。

## 要求

* Rails 5.2.x
* MySQL

## 安装

可选项：

将以下代码添加到 `~/.railsrc` 文件中:

```
-T
-m https://raw.githubusercontent.com/liukun-lk/rails_start_template/master/template.rb
```

## 使用

使用 `rails new` 命令来创建一个新的 Rails 项目:

```
rails new blog \
  --skip-coffee \
  -d mysql \
  -T \
  -m https://raw.githubusercontent.com/liukun-lk/rails_start_template/master/template.rb
```

如果你将上面的参数添加到 `~/.railsrc` 文件中，则只需要运行 `rails new blog` 即可。

