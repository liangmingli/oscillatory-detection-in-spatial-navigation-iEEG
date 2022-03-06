%% load data
load('example-epo.mat')

%% plot example trial
times = (1:2049)/512;
itrial = 11;

plot(times,data(itrial,:))
xlim([0 4])
xlabel('Time [s]')
ylabel('Voltages')
%% calculate time-frequency power 
F = 2.^[1:.5:5];
Fsample = 512;
wavenumber = 6;
B = nan(9,2049,48);
for itrial = 1:48
    eegsignal = data(itrial,:);
    [B(:,:,itrial),~,~]=BOSC_tf(eegsignal,F,Fsample,wavenumber);
end

%% fit background spectra
[pv,meanpower]=BOSC_bgfit(F,mean(B,3));

% try robust linear regression
pv2 = robustfit(F,mean(mean(B,3),2));

% plot spectra
figure()
empiricalpower = mean(mean(B,3),2);
plot(F,empiricalpower,'LineStyle','-','LineWidth',1)
hold on
plot(F,meanpower,'LineStyle','--','LineWidth',2) % linear regression BG
plot(F,foof_ap_fit,'LineStyle',':','LineWidth',3,'Color','k')
legend('empirical PSD','linear regression','FOOOF aperiodic fit')
xlim([1 32])
xticks([1 4 8 12 32])
xlabel('Frequency [Hz]')
ylabel('Power [au]')
%% get power threshold
percentilethresh = 0.95;
numcyclesthresh= 3;
[powthresh,durthresh]=BOSC_thresholds(Fsample,percentilethresh,numcyclesthresh,F,meanpower);

%% detect oscillations
Detect = nan(size(B));
for ifreq = 1:9
    for itrial = 1:48
        [~,Detect(ifreq,:,itrial)]=BOSC_detect(B(ifreq,:,itrial),powthresh(ifreq),durthresh(ifreq),Fsample);
    end
end

%% plot BOSC outputs
plot(F,mean(mean(Detect,3),2),'-o')

%% test the effects of different cycles of temporal thresholding
list_cyclesthres = [1,2,3,4,5,6];
list_detect_oscillations = nan(6,9);
for ii = 1:6
    [powthresh,durthresh]=BOSC_thresholds(Fsample,percentilethresh,list_cyclesthres(ii),F,meanpower);
    % detect
    Detect = nan(size(B));
    for ifreq = 1:9
        for itrial = 1:48
            [~,Detect(ifreq,:,itrial)]=BOSC_detect(B(ifreq,:,itrial),powthresh(ifreq),durthresh(ifreq),Fsample);
        end
    end
    list_detect_oscillations(ii,:) = mean(mean(Detect,3),2);
end

%% plot effects of different cycles of temporal thresholding
figure()
hold on
for ii = 1:6
    plot(F,list_detect_oscillations(ii,:)*100,'LineWidth',ii,'Color','k')
end
xlim([1 32])
xticks([1 4 8 12 32])
xlabel('Frequency [Hz]')
ylabel('Detected oscillations [%]')
legend('cycle=1','cycle=2','cycle=3','cycle=4','cycle=5','cycle=6')

%% plot example trial opverlaid with Pepisodes
times = (1:2049)/512;
% 8Hz overlay
itrial = 11;
ifreq = 5;
numcyclesthresh= 3;
[powthresh,durthresh]=BOSC_thresholds(Fsample,percentilethresh,numcyclesthresh,F,meanpower);
[H,detected]=BOSC_detect(B(ifreq,:,itrial),powthresh(ifreq),durthresh(ifreq),Fsample);
plot(times,data(itrial,:),'LineStyle','--')

overlaydata = data(itrial,:);
overlaydata(find(~detected)) = nan;

hold on
plot(times,overlaydata,'LineWidth',2,'Color','r')

xlim([0 4])
xlabel('Time [s]')
ylabel('Voltages')
legend('raw trace','Detected 8Hz')