function plotGLM(X,Y,beta)

figure(250);clf;
subplot(2,1,1);
plot(beta);
title('Betas For Concatonated Data');
subplot(2,1,2);
plot(Y);
hold on;
plot(X*beta);
title('Value vs Predicted on Training Set');
legend('Real','Prediction');

end