//+------------------------------------------------------------------+
//|                                                   SunScalper.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_label1 "SunScalper"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 clrLightBlue, clrBlue, clrYellow, clrGold, clrDarkOrange
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

input uint                 MaFastPeriod = 7;
input uint                 MaSlowPeriod = 33;
input ENUM_MA_METHOD       MaMethod = MODE_SMA;
input ENUM_APPLIED_PRICE   MaAppliedPrice = PRICE_CLOSE;

double MAOSBuffer[];
double ColorsBuffer[];
double FastBuffer[];
double SlowBuffer[];

int FastPeriod,
   SlowPeriod,
   fma_h,
   sma_h;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  
   FastPeriod = (int)(MaFastPeriod < 1 ? 1 : MaFastPeriod);
   SlowPeriod = (int)(MaSlowPeriod == FastPeriod ? FastPeriod + 1 : MaSlowPeriod < 1 ? 1 : MaSlowPeriod);
  
   SetIndexBuffer(0,MAOSBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorsBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,FastBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,SlowBuffer,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(MAOSBuffer,true);
   ArraySetAsSeries(ColorsBuffer,true);
   ArraySetAsSeries(FastBuffer,true);
   ArraySetAsSeries(SlowBuffer,true);
   
   ResetLastError();
   
   fma_h = iMA(NULL,PERIOD_CURRENT,FastPeriod,0, MaMethod,MaAppliedPrice);
   if (fma_h == INVALID_HANDLE) {
      return INIT_FAILED;
      Print("Faild fma_handle!");
   }
   
   sma_h = iMA(NULL,PERIOD_CURRENT,FastPeriod,0, MaMethod,MaAppliedPrice);
      if (sma_h == INVALID_HANDLE) {
      return INIT_FAILED;
      Print("Faild sma_handle!");
   }
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//---
   if (rates_total < 4) { 
      return (0); 
   }
   
   int limit = rates_total - prev_calculated;
   
   if(limit > 1) {
      limit = rates_total - 2;
      ArrayInitialize(MAOSBuffer, 0);
      ArrayInitialize(ColorsBuffer,4);
      ArrayInitialize(FastBuffer,0);
      ArrayInitialize(SlowBuffer,0);
   }
   
   int count = (limit > 1 ? rates_total : 1);
   int copied = 0;
   
   copied = CopyBuffer(fma_h,0,0, count, FastBuffer);
   
   if(copied != count){
      return(0);
   }
      
   copied = CopyBuffer(sma_h,0,0, count, FastBuffer);
   
   if(copied != count){
      return(0);
   }   
   
   for(int i = limit; i >= 0; i--) {
      MAOSBuffer[i] = FastBuffer[i] - SlowBuffer[i];
      ColorsBuffer[i] = 
      (MAOSBuffer[i] > 0  ? (MAOSBuffer[i] > MAOSBuffer[i + 1] ? 0 : 1) : MAOSBuffer[i] < 0 ? (MAOSBuffer[i] < MAOSBuffer[i + 1] ? 2 : 3) : 4);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
