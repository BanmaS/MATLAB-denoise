function snr = calcu_snr(clean_file,noisy_file)
%% to calculate the snr
cl=clean_file;
ny=noisy_file;
len=size(ny,1);   
clean=cl(1:len);   
Ps=sum(sum((clean-mean(mean(clean))).^2));%clean power
Pn=sum(sum((clean-ny).^2));           %noisy power
snr=10*log10(Ps/Pn);
end
