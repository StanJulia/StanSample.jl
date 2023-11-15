#
# Synthesize data.
# (1) the independent variable `w`.
#
w.max <- 5 # Max extent of the independent values
w <- expand.grid(seq(-w.max,w.max), seq(-w.max,w.max))
w <- complex(real=w[[1]], imaginary=w[[2]])
w <- w[Mod(w) <= w.max]
n <- length(w)
#
# (2) the dependent variable `z`.
#
beta <- c(-20+5i, complex(argument=2*pi/3, modulus=3/2))
sigma <- 2; rho <- 0.8 # Parameters of the error distribution
library(MASS) #mvrnorm
set.seed(17)
e <- mvrnorm(n, c(0,0), matrix(c(1,rho,rho,1)*sigma^2, 2))
e <- complex(real=e[,1], imaginary=e[,2])
z <- as.vector((X <- cbind(rep(1,n), w)) %*% beta + e)
#
# Fit the models.
#
print(beta, digits=3)
print(beta.hat <- solve(Conj(t(X)) %*% X, Conj(t(X)) %*% z), digits=3)
print(beta.r <- coef(lm(Re(z) ~ Re(w) + Im(w))), digits=3)
print(beta.i <- coef(lm(Im(z) ~ Re(w) + Im(w))), digits=3)
#
# Show some diagnostics.
#
par(mfrow=c(1,2))
res <- as.vector(z - X %*% beta.hat)
fit <- z - res
s <- sqrt(Re(mean(Conj(res)*res)))
col <- hsv((Arg(res)/pi + 1)/2, .8, .9)
size <- Mod(res) / s
plot(res, pch=16, cex=size, col=col, main="Residuals")
plot(Re(fit), Im(fit), pch=16, cex = size, col=col,
     main="Residuals vs. Fitted")

plot(Re(c(z, fit)), Im(c(z, fit)), type="n",
     main="Residuals as Fit --> Data", xlab="Real", ylab="Imaginary")
points(Re(fit), Im(fit), col="Blue")
points(Re(z), Im(z), pch=16, col="Red")
arrows(Re(fit), Im(fit), Re(z), Im(z), col="Gray", length=0.1)

col.w <-  hsv((Arg(w)/pi + 1)/2, .8, .9)
plot(Re(c(w, z)), Im(c(w, z)), type="n",
     main="Fit as a Transformation", xlab="Real", ylab="Imaginary")
points(Re(w), Im(w), pch=16, col=col.w)
points(Re(w), Im(w))
points(Re(z), Im(z), pch=16, col=col.w)
arrows(Re(w), Im(w), Re(z), Im(z), col="#00000030", length=0.1)
#
# Display the data.
#
par(mfrow=c(1,1))
pairs(cbind(w.Re=Re(w), w.Im=Im(w), z.Re=Re(z), z.Im=Im(z),
            fit.Re=Re(fit), fit.Im=Im(fit)), cex=1/2)
