always@(*)
begin
    case(1'b1)
        And: C={32'b0, A&B};
        OR: C={32'b0,A|B};
        Not: C={32'b0,~B};
        Neg: C={32'b0,(~B+1'b1)}; //have to use custom adder

        SHR: C={32'b0,B>>A[4:0]};
        SHL: C={32'b0,B<<A[4:0]};
        ROR: C={32'b0,(B>>A[4:0])|(B<<(32-A[4:0]))};
        //ADD:C={32'b0,adder_result};
        default: C=64'b0;
    endcase
end