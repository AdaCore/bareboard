------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2016, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with HAL;      use HAL;
with HAL.Time;

package NRF52_DK.Time is

   subtype Time_Ms is UInt64;

   function Clock return Time_Ms;

   procedure Delay_Ms (Milliseconds : UInt64);

   procedure Sleep (Milliseconds : UInt64) renames Delay_Ms;

   function Tick_Period return Time_Ms;

   type Tick_Callback is access procedure;

   function Tick_Subscriber (Callback : not null Tick_Callback) return Boolean;
   --  Return True if callback is already a tick event subscriber

   function Tick_Subscribe (Callback : not null Tick_Callback) return Boolean
     with Pre  => not Tick_Subscriber (Callback),
          Post => (if Tick_Subscribe'Result then Tick_Subscriber (Callback));
   --  Subscribe a callback to the tick event. The function return True on
   --  success, False if there's no more room for subscribers.

   function Tick_Unsubscribe (Callback : not null Tick_Callback) return Boolean
     with Pre  => Tick_Subscriber (Callback),
          Post => (if Tick_Unsubscribe'Result then not Tick_Subscriber (Callback));
   --  Unsubscribe a callback to the tick event. The function return True on
   --  success, False if the callback was not a subscriber.

   function HAL_Delay return not null HAL.Time.Any_Delays;
private

   type MB_Delays is new HAL.Time.Delays with null record;

   overriding
   procedure Delay_Microseconds (This : in out MB_Delays;
                                 Us   : Integer);

   overriding
   procedure Delay_Milliseconds (This : in out MB_Delays;
                                 Ms   : Integer);

   overriding
   procedure Delay_Seconds      (This : in out MB_Delays;
                                 S    : Integer);

end NRF52_DK.Time;
