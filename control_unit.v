`timescale 1ns/10ps
module control_unit (
    input Clock, Reset, Stop, CON_FF,
    input [31:0] IR,
    output reg Gra, Grb, Grc, Rin, Rout, BAout,
    output reg Yin, Zin, PCout, IncPC, MARin, MDRin, MDRout,
    output reg Read, Write, Clear,
    output reg ADD_op, SUB_op, MUL_op, DIV_op, SHR_op, SHRA_op, SHL_op, ROR_op, ROL_op, AND_op, OR_op, NEG_op, NOT_op,
    output reg HIin, LOin, CONin, PCin, IRin, OutPortin, Cout, Zlowout, Zhighout,
    output reg HIout, LOout, InPortout, Run
);

    parameter [5:0]
        reset_state = 6'd0,
        fetch0      = 6'd1,
        fetch1      = 6'd2,
        fetch2      = 6'd3,
        decode_state= 6'd50, 
        alu3        = 6'd4,
        alu5        = 6'd5,
        add4        = 6'd6,
        sub4        = 6'd7,
        and4        = 6'd8,
        or4         = 6'd9,
        shr4        = 6'd10,
        shra4       = 6'd11,
        shl4        = 6'd12,
        ror4        = 6'd13,
        rol4        = 6'd14,
        addi4       = 6'd15,
        andi4       = 6'd16,
        ori4        = 6'd17,
        mul3        = 6'd18,
        mul4        = 6'd19,
        mul5        = 6'd20,
        mul6        = 6'd21,
        div3        = 6'd22,
        div4        = 6'd23,
        div5        = 6'd24,
        div6        = 6'd25,
        neg3        = 6'd26,
        not3        = 6'd27,
        alu_single4 = 6'd28,
        mem3        = 6'd29,
        mem4        = 6'd30,
        ld5         = 6'd31,
        ld6         = 6'd32,
        ld7         = 6'd33,
        ldi5        = 6'd34,
        st5         = 6'd35,
        st6         = 6'd36,
        st7         = 6'd37,
        br3         = 6'd38,
        br4         = 6'd39,
        br5         = 6'd40,
        br6         = 6'd41,
        jr3         = 6'd42,
        jal3        = 6'd43,
        jal4        = 6'd44,
        in3         = 6'd45,
        out3        = 6'd46,
        mfhi3       = 6'd47,
        mflo3       = 6'd48,
        halt_state  = 6'd49;

    reg [5:0] present_state;

    always @(posedge Clock, posedge Reset) begin
        if (Reset == 1'b1) begin
            present_state <= reset_state;
        end
        else if (Stop == 1'b1) begin
            present_state <= halt_state;
        end
        else begin
            case (present_state)
                reset_state: present_state <= fetch0;
                fetch0:      present_state <= fetch1;
                fetch1:      present_state <= fetch2;
                fetch2:      present_state <= decode_state; 
                
                decode_state: begin
                    case (IR[31:27])
                        5'b00000: present_state <= alu3;  
                        5'b00001: present_state <= alu3;  
                        5'b00010: present_state <= alu3;  
                        5'b00011: present_state <= alu3;  
                        5'b00100: present_state <= alu3;  
                        5'b00101: present_state <= alu3;  
                        5'b00110: present_state <= alu3;  
                        5'b00111: present_state <= alu3;  
                        5'b01000: present_state <= alu3;  
                        5'b01001: present_state <= alu3;  
                        5'b01010: present_state <= alu3;  
                        5'b01011: present_state <= alu3;  
                        5'b01100: present_state <= div3;  
                        5'b01101: present_state <= mul3;  
                        5'b01110: present_state <= neg3;  
                        5'b01111: present_state <= not3;  
                        5'b10000: present_state <= mem3;  
                        5'b10001: present_state <= mem3;  
                        5'b10010: present_state <= mem3;  
                        5'b10011: present_state <= jal3;  
                        5'b10100: present_state <= jr3;   
                        5'b10101: present_state <= br3;   
                        5'b10110: present_state <= in3;   
                        5'b10111: present_state <= out3;  
                        5'b11000: present_state <= mfhi3; 
                        5'b11001: present_state <= mflo3; 
                        5'b11010: present_state <= fetch0; // NOP
                        5'b11011: present_state <= halt_state; // HALT
                        default:  present_state <= fetch0;
                    endcase
                end

                alu3: begin
                    case (IR[31:27])
                        5'b00000: present_state <= add4;
                        5'b00001: present_state <= sub4;
                        5'b00010: present_state <= and4;
                        5'b00011: present_state <= or4;
                        5'b00100: present_state <= shr4;
                        5'b00101: present_state <= shra4;
                        5'b00110: present_state <= shl4;
                        5'b00111: present_state <= ror4;
                        5'b01000: present_state <= rol4;
                        5'b01001: present_state <= addi4;
                        5'b01010: present_state <= andi4;
                        5'b01011: present_state <= ori4;
                        default:  present_state <= fetch0;
                    endcase
                end

                add4:  present_state <= alu5;
                sub4:  present_state <= alu5;
                and4:  present_state <= alu5;
                or4:   present_state <= alu5;
                shr4:  present_state <= alu5;
                shra4: present_state <= alu5;
                shl4:  present_state <= alu5;
                ror4:  present_state <= alu5;
                rol4:  present_state <= alu5;
                addi4: present_state <= alu5;
                andi4: present_state <= alu5;
                ori4:  present_state <= alu5;
                alu5:  present_state <= fetch0;

                mem3: present_state <= mem4;
                mem4: begin
                    case (IR[31:27])
                        5'b10000: present_state <= ld5;
                        5'b10001: present_state <= ldi5;
                        5'b10010: present_state <= st5;
                        default:  present_state <= fetch0;
                    endcase
                end

                ld5:  present_state <= ld6;
                ld6:  present_state <= ld7;
                ld7:  present_state <= fetch0;
                ldi5: present_state <= fetch0;
                st5:  present_state <= st6;
                st6:  present_state <= st7;
                st7:  present_state <= fetch0;

                mul3: present_state <= mul4;
                mul4: present_state <= mul5;
                mul5: present_state <= mul6;
                mul6: present_state <= fetch0;
                div3: present_state <= div4;
                div4: present_state <= div5;
                div5: present_state <= div6;
                div6: present_state <= fetch0;

                neg3: present_state <= alu_single4;
                not3: present_state <= alu_single4;
                alu_single4: present_state <= fetch0;

                br3: present_state <= br4;
                br4: present_state <= br5;
                br5: present_state <= br6;
                br6: present_state <= fetch0;
                jr3: present_state <= fetch0;
                jal3: present_state <= jal4;
                jal4: present_state <= fetch0;

                in3:   present_state <= fetch0;
                out3:  present_state <= fetch0;
                mfhi3: present_state <= fetch0;
                mflo3: present_state <= fetch0;
                
                halt_state: present_state <= halt_state;
                default: present_state <= fetch0;
            endcase
        end
    end

    always @(present_state or CON_FF) begin
        Gra <= 0; Grb <= 0; Grc <= 0; Rin <= 0; Rout <= 0; BAout <= 0;
        Yin <= 0; Zin <= 0; PCout <= 0; IncPC <= 0; MARin <= 0; MDRin <= 0; MDRout <= 0;
        Read <= 0; Write <= 0; Clear <= 0;
        ADD_op <= 0; SUB_op <= 0; MUL_op <= 0; DIV_op <= 0; SHR_op <= 0; SHRA_op <= 0; SHL_op <= 0; 
        ROR_op <= 0; ROL_op <= 0; AND_op <= 0; OR_op <= 0; NEG_op <= 0; NOT_op <= 0;
        HIin <= 0; LOin <= 0; CONin <= 0; PCin <= 0; IRin <= 0; OutPortin <= 0; Cout <= 0;
        Zlowout <= 0; Zhighout <= 0; HIout <= 0; LOout <= 0; InPortout <= 0;
        Run <= 1;

        case (present_state)
            fetch0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            fetch1: begin
                Zlowout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
            end
            fetch2: begin
                MDRout <= 1; IRin <= 1;
            end

            alu3: begin Grb <= 1; Rout <= 1; Yin <= 1; end
            
            add4:  begin Grc <= 1; Rout <= 1; ADD_op <= 1; Zin <= 1; end
            sub4:  begin Grc <= 1; Rout <= 1; SUB_op <= 1; Zin <= 1; end
            and4:  begin Grc <= 1; Rout <= 1; AND_op <= 1; Zin <= 1; end
            or4:   begin Grc <= 1; Rout <= 1; OR_op <= 1; Zin <= 1; end
            shr4:  begin Grc <= 1; Rout <= 1; SHR_op <= 1; Zin <= 1; end
            shra4: begin Grc <= 1; Rout <= 1; SHRA_op <= 1; Zin <= 1; end
            shl4:  begin Grc <= 1; Rout <= 1; SHL_op <= 1; Zin <= 1; end
            ror4:  begin Grc <= 1; Rout <= 1; ROR_op <= 1; Zin <= 1; end
            rol4:  begin Grc <= 1; Rout <= 1; ROL_op <= 1; Zin <= 1; end
            addi4: begin Cout <= 1; ADD_op <= 1; Zin <= 1; end
            andi4: begin Cout <= 1; AND_op <= 1; Zin <= 1; end
            ori4:  begin Cout <= 1; OR_op <= 1; Zin <= 1; end

            alu5: begin Zlowout <= 1; Gra <= 1; Rin <= 1; end

            mem3: begin Grb <= 1; BAout <= 1; Yin <= 1; end
            mem4: begin Cout <= 1; ADD_op <= 1; Zin <= 1; end
            ld5:  begin Zlowout <= 1; MARin <= 1; end
            ld6:  begin Read <= 1; MDRin <= 1; end
            ld7:  begin MDRout <= 1; Gra <= 1; Rin <= 1; end
            ldi5: begin Zlowout <= 1; Gra <= 1; Rin <= 1; end
            st5:  begin Zlowout <= 1; MARin <= 1; end
            st6:  begin Gra <= 1; Rout <= 1; MDRin <= 1; end
            st7:  begin Write <= 1; end

            mul3: begin Gra <= 1; Rout <= 1; Yin <= 1; end
            mul4: begin Grb <= 1; Rout <= 1; MUL_op <= 1; Zin <= 1; end
            mul5: begin Zlowout <= 1; LOin <= 1; end
            mul6: begin Zhighout <= 1; HIin <= 1; end
            div3: begin Gra <= 1; Rout <= 1; Yin <= 1; end
            div4: begin Grb <= 1; Rout <= 1; DIV_op <= 1; Zin <= 1; end
            div5: begin Zlowout <= 1; LOin <= 1; end
            div6: begin Zhighout <= 1; HIin <= 1; end

            neg3: begin Grb <= 1; Rout <= 1; NEG_op <= 1; Zin <= 1; end
            not3: begin Grb <= 1; Rout <= 1; NOT_op <= 1; Zin <= 1; end
            alu_single4: begin Zlowout <= 1; Gra <= 1; Rin <= 1; end

            br3: begin Gra <= 1; Rout <= 1; CONin <= 1; end
            br4: begin PCout <= 1; Yin <= 1; end
            br5: begin Cout <= 1; ADD_op <= 1; Zin <= 1; end
            br6: begin
                Zlowout <= 1;
                if (CON_FF == 1'b1) PCin <= 1;
            end

            jr3:  begin Gra <= 1; Rout <= 1; PCin <= 1; end
            jal3: begin PCout <= 1; Grb <= 1; Rin <= 1; end
            jal4: begin Gra <= 1; Rout <= 1; PCin <= 1; end

            in3:   begin InPortout <= 1; Gra <= 1; Rin <= 1; end
            out3:  begin Gra <= 1; Rout <= 1; OutPortin <= 1; end
            mfhi3: begin HIout <= 1; Gra <= 1; Rin <= 1; end
            mflo3: begin LOout <= 1; Gra <= 1; Rin <= 1; end

            halt_state: begin Run <= 0; end
            reset_state: begin Clear <= 1; end
            default: begin end
        endcase
    end
endmodule