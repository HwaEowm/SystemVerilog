# ALU(Arithmetic Logic Unit)
## Summary

ALU는 여러 가산, 감산과 같은 산술연산과 AND, OR과 같은 논리 연산을 하나의 유닛으로 만든 것이다. 컴퓨터 시스템의 심장과도 같은 유닛이다. 

연산 결과는 MUX를 통해 출력한다.

| Control   Signal |    Result   |
|:----------------:|:-----------:|
|        000       |   Addition  |
|        001       | Subtraction |
|        010       |     AND     |
|        011       |      OR     |
|        101       |     SLT     |

`flag` 는 ALU의 연산 결과에 대한 여러 정보를 추가로 출력하는 역할을 한다. `N, Z, C, V` 와 같은 플래그 출력을 통해 연산 결과가 음수인지(Negative), `0` 인지(Zero), 자리올림이 발생했는지(Carry), 오버플로우가 발생했는지(oVerflow)를 알 수 있다.

|   Flag   |                                  Condition                                 |
|:--------:|:--------------------------------------------------------------------------|
| Negative | 2의 보수 체계에서 연산 결과의 MSB 확인                                         |
|   Zero   | 연산 결과의 모든 비트를 NOR 연산                                               |
|   Carry  | Adder 의 Carry out 확인                                                     |
| oVerflow | 부호가 같은 두 피연산자 연산시 결과의 부호가 반전됐는지 확인 |

플래그가 N개의 출력을 표시하지만, 인코더로 출력 도선을 log(2)N 으로 묶어 하드웨어 자원을 절약하지 않는다. 출력을 N개의 도선으로 나누는 이유는 그 상태들이 중첩되어 나타날 수 있기 때문이다. 가령 연산 결과가 음수이면서 오버플로우가 발생했다면 `N` 과 `V` 를 둘 다 나타낼 수 있다.

하드웨어 설계시 ALU와 연결되는 다른 모듈에 ALU의 플래그가 결선된다면 복잡성과 소모 자원이 크게 증가하기 때문에, 연산 결과만으로 어떤 플래그가 활성화되었는지를 확인할 수 있도록 MUX에 통합시킨다. `SLT` (Set if Less Than) 가 그 예시며, `N xor V` 를 연산하여 MUX의 입력에 연결시킨다.

## Design

[alu.sv](/rtl/alu/alu.sv)

### RTL Analysis Schematic

![alu_module](/images/circuits/alu_module.svg)

### RTL Synthesis Schematic

![alu_schematic](/images/rtl_schematic/alu.svg)

### Timing Report

설계된 ALU는 순수 CL 이므로, 클럭 제약 조건 없이 물리적인 최대 전파 지연만을 측정함.

 · **Critical Path** : 8.412ns
 
 · **Max Frequency** : About 118.88MHz (1/8.412n)
 
 · **Path Endpoints** : b_in[1] -> z_out
 
 · **Logic Level** : 8  (CARRY4=2 IBUF=1 LUT2=1 LUT4=1 LUT5=1 LUT6=1 OBUF=1)

### Utilization Report

| Ref Name | Functional Category | Used | Description |
| :--: | :--: | :--: | :--------------------------- |
| **IBUF** | IO | 19 | 입력 핀 버퍼 (`a_in`, `b_in`, `s_in`) |
| **OBUF** | IO | 12 | 출력 핀 버퍼 (`y_out`, flags) |
| **CARRY4** | CarryLogic | 5 | 고속 덧셈/뺄셈 및 비교 연산을 위한 전용 연산 자원 |
| **LUT6** | LUT | 10 | 6-input LUT |
| **LUT5** | LUT | 1 | 5-input LUT |
| **LUT4** | LUT | 2 | 4-input LUT |
| **LUT3** | LUT | 8 | 3-input LUT |
| **LUT2** | LUT | 18 | 2-input LUT |

## Testbench

각 `opcode` 에 대해 `a_in` 과 `b_in` 을 부호있는 8bit 범위인 `-128 ~ 127` 내에서 검증하였음.

[tb_alu.sv](/tb/tb_alu.sv)

## Syntax Note

`always_comb` 문 안의 동작들 중 플래그 `C` 와 `V` 는 그것이 평가(evaluation)되기 전 `0` 으로 초기화한다. `always_comb` 의 명시로 불필요한 래치(latch)가 생성되는 것을 방지하지만, 조건 분기에 따라 평가와 갱신(assignment)이 이루어지지 않는 신호는 엄밀하게 초기값을 지정해주는 습관을 들이는 것이 좋다.

`Z` 와 `N` 플래그는 조건 분기에 관계없이 항상 평가가 이루어지므로 다른 플래그처럼 초기화를 해주도록 명시한다면 하드웨어 합성시 최적화에 방해가 될 수 있다.

덧셈 모드(s_in: `000`) 일 때 `{c_out, y_out} = {1'b0, a_in} + {1'b0, b_in};` 코드는 가산기를 합성할 때 의도대로 `C` 를 출력하도록 하기 위함이다. 좌변의 `{c_out, y_out}` 은 1 + 8 bit로 총 9bit 데이터이나, 이를 평가할 때 단순히 `a_in + b_in` 으로 작성시 시스템은 부호 체계를 유지하기 위해 9bit 로 확장하고 MSB 에 원래 입력신호의 MSB 와 동일한 값으로 채운다. 가령 `1000 0000` 이 입력으로 들어오면, 이것이 음수이므로 평가시 `1 1000 0000` 으로 자동적인 부호 확장이 일어나게 된다. 따라서 `{1'b0, a_in} + {1'b0, b_in};` 와 같이 입력의 MSB 앞에 `0` 으로 확장시켜 정상적인 `C` 출력이 갱신되도록 해주어 논리적 버그를 방지한다.
