# Full Adder (전가산기)

## Summary

입력 `A` `B` `Cin` 과 출력 `S` `Co` 를 신호로 사용하며, `S` 는 합(Sum),  `Cin` 과 `Co` 는 각각 Carry in 과 Carry out 을 나타낸다.

기본적으로 전가산기 모듈 하나만으로는 1bit 끼리의 덧셈 연산만 가능하나, 앞단 모듈의 `Co` 와 뒷단 모듈의 `Cin` 을 결선하여 직렬로 연결하면 여러 bit 를 동시에 연산하는 것이 가능하다.

| A | B | Cin |   | S | Co |
|:-:|:-:|:---:|:-:|:-:|:--:|
| 0 | 0 |  0  |   | 0 |  0 |
| 0 | 0 |  1  |   | 1 |  0 |
| 0 | 1 |  0  |   | 1 |  0 |
| 0 | 1 |  1  |   | 0 |  1 |
| 1 | 0 |  0  |   | 1 |  0 |
| 1 | 0 |  1  |   | 0 |  1 |
| 1 | 1 |  0  |   | 0 |  1 |
| 1 | 1 |  1  |   | 1 |  1 |

단순화한 논리식은 다음과 같다.

`S = A ^ B ^ Cin`

`Co = AB + ACin + BCin`

## Design 1

상술한 진리표를 통해 하위 모듈을 생성한 후 직렬로 이어붙이는 방식으로 구현이 가능하다.

[full_adder.v](full_adder.v)

위의 코드는 전가산기 모듈을 직렬 연결하여 4bit 전가산기를 구현한 것이다.

### 1 bit Full Adder (하위 모듈)

``` verilog
module fulladd(a, b, c_in, q, c_out);
    
    input a, b, c_in;
    output q, c_out;
    
    assign q  = a ^ b ^ c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
    
endmodule
```

1 bit 입력 3개를 받아 그 합과 Carry out 을 출력하는 조합논리회로(이하 CL) 모듈이다.

### 4 bit ripple adder (상위 모듈)

``` verilog
module adder_ripple(a, b, q);
    input [3:0] a, b;
    output [3:0] q;
    wire [3:0] co;

    fulladd add0 (.a(a[0]), .b(b[0]), .c_in(1'b0),  .q(q[0]), .c_out(co[0]));
    fulladd add1 (.a(a[1]), .b(b[1]), .c_in(co[0]), .q(q[1]), .c_out(co[1]));
    fulladd add2 (.a(a[2]), .b(b[2]), .c_in(co[1]), .q(q[2]), .c_out(co[2]));
    fulladd add3 (.a(a[3]), .b(b[3]), .c_in(co[2]), .q(q[3]), .c_out(co[3])); 
endmodule
```

4 bit 연산을 위해 앞서 선언한 `fulladd` 하위 모듈 4개를 인스턴스화 한다. `co` 신호를 통해 앞단 하위 모듈의 carry out 이 뒷단 하위 모듈의 carry in 으로 할당되도록 결선한다. 맨 앞단 모듈의 carry in 은 0 이 입력되어야 하므로 `1'b0` (binary 1 bit 0) 를 인가한다.'

## Design 2

Verilog 에는 Cell Library 라는 것이 있으며, Vendor 에서 해당 기능을 가지는 회로 구성을 미리 최적화하여 모듈화한 것을 라이브러리로써 제공한다. 이를 활용하여 진리표를 통한 유도 없이 간단하게 전가산기 모듈을 구현하는 것이 가능하다.


## Syntax Note

### 출력 포트의 생략

Verilog 는 기본적으로 상위 모듈에서 하위 모듈의 **출력** 포트를 결선할 필요가 없을 때 인스턴스에서 그 포트명을 생략할 수 있다. 이렇게 하면 실제로 코드 합성 시 물리적으로 어느 노드로도 이어지지 않게 된다. (다만 이는 floating 상태가 되지 않으며 본래 노드의 확실한 논리 레벨을 유지한다.)

### Named Instatiation

Verilog 는 상위 모듈에서 하위 모듈의 포트와 결선할 때 다른 방식으로 코드를 쓸 수 있다.

<br>

`fulladd add0 (a[0], b[0], 1'b0, q[0], co[0]);`

위 방식은 프로그래밍 언어들에서 익숙한 방식으로 다가오며, 위의 식은 아래와 같이 쓸 수 있다.

`fulladd add0 (.a(a[0]), .b(b[0]), .c_in(1'b0), .q(q[0]), .c_out(co[0]));`

`.a(a[0])` 에서는 먼저 `.a` 와 같이 `.` 을 붙여 하위 모듈의 포트명을 쓰며, 괄호 안에는 상위 모듈의 신호를 쓴다.

추가로 이 방식은 포트명의 순서를 다르게 써도 되며, 가령 다음과 같이 쓰는 것도 허용된다.

`fulladd add0 (.c_out(co[0]), .c_in(1'b0), .b(b[0]), .q(q[0]), .a(a[0]));`

이 방식은 코드의 행이 길어진다는 단점이 있으나, 하위 모듈의 포트명만 알고 있으면 순서 상관없이 신호 할당이 가능해져 코드 작성이 편리하고, 포트명이 확실하게 명시되어 다른 작업자가 모듈 기능을 파악하기 쉽다는 장점이 있다. 이 방식이 실무에서 널리 쓰이는 방식이며, 이후 코드는 이 방식으로 작성한다.
