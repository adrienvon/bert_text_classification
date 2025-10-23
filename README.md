# bert_text_classification

基于 BERT 模型的中文文本分类工具。

## 环境

python 3.7

torch 1.7

tqdm

sklearn

transformers 4.8.1

## 安装指南

### 快速安装（推荐）

#### Windows

```powershell
# CPU 版本
.\scripts\install.ps1 -device cpu

# GPU 版本（CUDA 11.1）
.\scripts\install.ps1 -device gpu -cuda_version 111
```

#### Linux / macOS

```bash
# CPU 版本
bash scripts/install.sh cpu

# GPU 版本（CUDA 11.1）
bash scripts/install.sh gpu 111
```

**⚠️ GPU 用户**: 运行 `nvidia-smi` 查看 CUDA 版本后选择对应脚本参数  
**💡 详细说明**: 查看 [scripts/README.md](scripts/README.md)

## 中文数据集

从 THUCNews 中随机抽取20万条新闻标题，一共有10个类别：财经、房产、股票、教育、科技、社会、时政、体育、游戏、娱乐，每类2万条标题数据。数据集按如下划分：

- 训练集：18万条新闻标题，每个类别的标题数为18000
- 验证集：1万条新闻标题，每个类别的标题数为1000
- 测试集：1万条新闻标题，每个类别的标题数为1000

可以按照 data 文件夹中的数据格式来准备自己任务所需的数据，并调整 config.py 中的相关配置参数。

## 预训练 BERT 模型

从 huggingface 官网上下载 bert-base-chinese 模型权重、配置文件和词典到 pretrained_bert 文件夹中，下载地址：https://huggingface.co/bert-base-chinese/tree/main

## 模型训练

文本分类模型训练：

```shell
python main.py --mode train --data_dir ./data --pretrained_bert_dir ./pretrained_bert
```

训练中间日志如下：

<img src="https://github.com/zejunwang1/bert_text_classification/blob/main/image/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20210901153428.png?raw=true" alt="微信截图_20210901154723" style="zoom:67%;" />

模型在验证集上的效果如下：

<img src="https://github.com/zejunwang1/bert_text_classification/blob/main/image/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20210901154723.png?raw=true" alt="微信截图_20210901154723" style="zoom:67%;" />

### Demo演示

文本分类 demo 展示：

```shell
python main.py --mode demo --data_dir ./data --pretrained_bert_dir ./pretrained_bert
```

<img src="https://github.com/zejunwang1/bert_text_classification/blob/main/image/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20210901155158.png?raw=true" alt="微信截图_20210901155158" style="zoom:80%;" />

### 模型预测

对 data 文件夹下的 input.txt 中的文本进行分类预测：

```shell
python main.py --mode predict --data_dir ./data --pretrained_bert_dir ./pretrained_bert --input_file ./data/input.txt
```

输出如下结果：

<img src="https://github.com/zejunwang1/bert_text_classification/blob/main/image/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20210901155310.png?raw=true" alt="微信截图_20210901155310" style="zoom:80%;" />

