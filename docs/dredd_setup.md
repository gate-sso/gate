# Dredd Setup

Dredd is used to run test, to validate the API Blueprint againts Backend Implementation.

### Install npm 

On Mac OS

```
brew install node
```

On Linux

```
apt-get install npm
```

### Install dredd

To install dredd globally run 
```
npm install -g dredd
```

Before you run the dredd please make sure you've run the `bundler install` and fill the `env` file

### Running dredd

Running without debug
```
dredd
```

Running with debug mode
```
dredd --loglevel debug
```
