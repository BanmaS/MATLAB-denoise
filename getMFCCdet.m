function MFCCdet=getMFCCdet(MFCCs, giveMFCCnums)
    %% MFCC defs
    numberMFCC=size(MFCCs,2);
    onedet=zeros(1,numberMFCC-1);
    twodet=zeros(1,numberMFCC-2);
    for i=1:numberMFCC-1
        onedet(i)=MFCCs(i+1)-MFCCs(i);
    end
    
    for i=1:numberMFCC-2
        twodet(i)=MFCCs(i+2)-2*MFCCs(i+1)+MFCCs(i);
    end
    
    MFCCdet=[onedet(1:giveMFCCnums/2),twodet(1:giveMFCCnums/2)];
end