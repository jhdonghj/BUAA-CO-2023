P4P5P6P7对拍辅助工具，由纪郅炀制作
使用方法：
将标准输出copy到answer.txt，你的输出copy到yours.txt
然后打开python文件，运行
会返回一定报错信息。
该工具支持：
1、忽略掉时间（P5及以后需要输出运行时间，而mars不会）
2、忽略掉同一时间内同时读写带来的输出顺序问题
3、忽略掉零号寄存器的相关行为输出

注：
1、该工具设计初衷是和魔改版mars进行对拍，如果和同学对拍不保证一定没有bug（当然，如果有会直接运行时错误）
2、copy结果时，务必保证没有多余回车符和多余输出信息，允许每一行前面有空格，但空格一定要对齐（因为要用字符串排序消除输出顺序问题）

2023.12.2