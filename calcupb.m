function p_b = calcupb(frame1, frame2, numberPB)
    %% --Pitch correlation
    f1=fft(frame1);
    f1sq=abs(f1).^2;
    f2=fft(frame2);
    f2sq=abs(f2).^2;
    w_b=get_wb();


    for b=1:size(w_b,1)
        u1(1,b)=sum(real(f1.*conj(f2)).*w_b(b,:));
        d1(1,b)=sum(f1sq.*w_b(b,:));
        d2(1,b)=sum(f2sq.*w_b(b,:));
    end

    p_b_all=u1./sqrt(d1.*d2);
    p_b=p_b_all(1:numberPB);
end