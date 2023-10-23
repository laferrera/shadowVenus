class Envelope{
  // adr are in Seconds
  // s is 0,1.0
  float a;
  float d;
  float s;
  float r;
  float aCoeff;
  float dCoeff;
  float rCoeff;
  float aTarget = 0.0;
  float M_E = 2.71828182845904523536028747135266250;
  
  boolean gate = false;
  float curOut = 0;
  int mode = 0; 
  // 0 is idle
  // 1 is attack
  // 2 is decay
  // 3 is sustain
  // 4 is release
  
  Envelope(float _a, float _d, float _s, float _r){
    a = _a;
    d = _d;
    s = _s;
    r = _r;
    SetCoefficients();
    Print();
  }
  
  void SetCoefficients(){
    // attack
    if(a > 0){
      float x = a;
      float shape = 0;
      float target = 9.f * pow(x, 10.f) + 0.3 * x + 1.01f;
      aTarget = target;
      float logTarget = log(1.f - (1.f / target)); // -1 for decay
      aCoeff = 1.f - exp(logTarget / (a * _frameRate)); // *1.f - exp(logTarget / (timeInS * sample_rate_))
      
    } else{
      //instant change
      aCoeff = 1.f;
    }
    
    // decay
    if(d > 0.f){
      float target = log(1. / M_E);
      dCoeff = 1.f - exp(target / (d * _frameRate));
    } else {
      //instant change
      dCoeff = 1.f;
    }
    
    // release 
    if( r > 0.f){
      float target = log(1. / M_E);
      rCoeff = 1.f - exp(target / (r * _frameRate));
    } else {
      //instant change
      rCoeff = 1.f;
    }
    
  }
  
  void Print(){
    println("a: ", a);
    println("d: ", d);
    println("s: ", s);
    println("r: ", r);
    println("aCoeff: ", aCoeff);
    println("dCoeff: ", dCoeff);
    println("rCoeff: ", rCoeff);
    println("aTarget: ", aTarget);
  }
    
  void Retrigger(boolean hard){
    mode = 1;
    if(hard) curOut = 0;
  }
  
  
  float Process(boolean _g){
    float out = 0;
    if(_g && !gate){ // rising edge , attack
      mode = 1;
    } 
    //else if (!_g && gate) { // falling edge, release
    //  mode = 4;
    //} 
    gate = _g;
    if(mode > 1 && !gate){ 
      mode = 4;
    }
    
    
    // if decay, target is sus level
    // else release target is below zero
    float target = (mode == 2) ? s : -0.01f;
    
    // set coeff here so we can do same logic for 
    // decay and release
    float coeff = aCoeff;
    if(mode == 2){
      coeff = dCoeff;
    } else if(mode == 4){
      coeff = rCoeff;
    }
    
    switch(mode){
      // idle
      case(0):
        out = 0;
        break;
      // attack
      case(1):
        curOut += coeff * (aTarget - curOut);
        if(curOut > 1.0){
          curOut = 1.0; 
          mode = 2; // switch to decay
        }
        out = curOut;
        break;
      //decay & release
      case(2):
      case(4):
        curOut += coeff * (target - curOut);
        //curOut -= coeff * (target - coeff);
        out = curOut;
        if(curOut < 0.0){
          curOut = 0.0;
          out = 0.0;
          mode = 0;
        }
        break; //<>//
      default:
        break;
    }
    
    return out;
  }
  
}

  public enum WAVEFORM{
        WAVE_SIN,
        WAVE_TRI,
        WAVE_SAW,
        WAVE_RAMP,
        WAVE_SQUARE,
        WAVE_POLYBLEP_TRI,
        WAVE_POLYBLEP_SAW,
        WAVE_POLYBLEP_SQUARE,
        WAVE_LAST,
    };

class Oscillator{
        float sr_;
        float sr_recip_;
        float freq_      = 100.0f;
        float amp_       = 0.5f;
        float pw_        = 0.5f;
        float pw_rad_    = pw_ * TWO_PI;
        float phase_     = 0.0f;
        float phase_inc_ = CalcPhaseInc(freq_);
        float last_out_ = 0.0f;
        //int waveform_  = 0;//WAVE_SIN;
        WAVEFORM waveform_  = WAVEFORM.WAVE_SIN;        
        boolean eoc_     = true;
        boolean eor_     = true;
    
  
  Oscillator(float sampleRate){
      sr_  = sampleRate;
      sr_recip_ = 1.0f / sampleRate;  
  }
  
  float CalcPhaseInc(float f){
    return (TWO_PI * f) * sr_recip_;
  }
  
  void SetFreq(float f){
    freq_      = f;
    phase_inc_ = CalcPhaseInc(f);
  }
  void SetAmp(float a){
    amp_      = a;
  }
 
  
float Process()
{
    float out, t;
    switch(waveform_)
    {
        case WAVE_SIN: out = sin(phase_); break;
        case WAVE_TRI:
            t   = -1.0f + (2.0f * phase_ * 1/TWO_PI);
            //out = 2.0f * (fabsf(t) - 0.5f);
            out = 2.0f * (abs(t) - 0.5f);
            break;
        case WAVE_SAW:
            out = -1.0f * (((phase_ * 1/TWO_PI * 2.0f)) - 1.0f);
            break;
        case WAVE_RAMP: out = ((phase_ * 1/TWO_PI * 2.0f)) - 1.0f; break;
        case WAVE_SQUARE: out = phase_ < pw_rad_ ? (1.0f) : -1.0f; break;
        case WAVE_POLYBLEP_TRI:
            t   = phase_ * 1/TWO_PI;
            out = phase_ < PI ? 1.0f : -1.0f;
            out += Polyblep(phase_inc_, t);
            //out -= Polyblep(phase_inc_, mod(t + 0.5f, 1.0f));
            out -= Polyblep(phase_inc_, (t + 0.5f) % (1.0f));            
            // Leaky Integrator:
            // y[n] = A + x[n] + (1 - A) * y[n-1]
            out       = phase_inc_ * out + (1.0f - phase_inc_) * last_out_;
            last_out_ = out;
            break;
        case WAVE_POLYBLEP_SAW:
            t   = phase_ * 1/TWO_PI;
            out = (2.0f * t) - 1.0f;
            out -= Polyblep(phase_inc_, t);
            out *= -1.0f;
            break;
        case WAVE_POLYBLEP_SQUARE:
            t   = phase_ * 1/TWO_PI;
            out = phase_ < pw_rad_ ? 1.0f : -1.0f;
            out += Polyblep(phase_inc_, t);
            //out -= Polyblep(phase_inc_, mod(t + (1.0f - pw_), 1.0f));
            out -= Polyblep(phase_inc_, (t + (1.0f - pw_)) % (1.0f));            
            out *= 0.707f; // ?
            break;
        default: out = 0.0f; break;
    }
    phase_ += phase_inc_;
    if(phase_ > TWO_PI)
    {
        phase_ -= TWO_PI;
        eoc_ = true;
    }
    else
    {
        eoc_ = false;
    }
    eor_ = (phase_ - phase_inc_ < PI && phase_ >= PI);

    return out * amp_;
}
  
float Polyblep(float phase_inc, float t){
    float dt = phase_inc * 1/TWO_PI;
    if(t < dt)
    {
        t /= dt;
        return t + t - t * t - 1.0f;
    }
    else if(t > 1.0f - dt)
    {
        t = (t - 1.0f) / dt;
        return t * t + t + t + 1.0f;
    }
    else
    {
        return 0.0f;
    }
}
  
  
}
