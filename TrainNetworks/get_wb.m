function w_b=get_wb()
%% Triangle filter
    frameLength=0.02; 
    frameOverlap=0.01; 
    fs=8000;
    windowLength=frameLength*fs;
    windowOverlap=frameOverlap*fs;
    w_b=zeros(17,windowLength);

    
    w_b(1,1:4)=[1 0.75 0.5 0.25];
    temp_wb=[0.25 0.5 0.75 1 0.75 0.5 0.25];
    for b=2:8
        w_b(b,2+4*(b-2):4*b)=temp_wb;
    end
    w_b(9,30:40)=[0.25 0.5 0.75 1 0.875 0.75 0.625 0.5 0.375 0.25 0.125];
    temp_wb=zeros(1,15);
    for i=1:15
        if i<9
            temp_wb(i)=0.125*i;
        else
            temp_wb(i)=2-0.125*i;
        end
    end
    for b=10:12
        w_b(b,34+8*(b-10):48+8*(b-10))=temp_wb;
    end
    w_b(13,58:65)=temp_wb(1:8);
    for i=1:31
        if i<17
            temp_wb(i)=0.0625*i;
        else
            temp_wb(i)=2-0.0625*i;
        end
    end
    w_b(13,66:80)=temp_wb(17:31);
    w_b(14,66:96)=temp_wb;
    w_b(15,82:112)=temp_wb;
    w_b(16,98:113)=temp_wb(1:16);
    for i=1:63
        if i<33
            temp_wb(i)=0.03125*i;
        else
            temp_wb(i)=2-0.03125*i;
        end
    end
    w_b(16,114:144)=temp_wb(33:63);
    w_b(17,114:160)=temp_wb(1:47);
end