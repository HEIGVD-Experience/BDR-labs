<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Http\Request;

class SendMail extends Mailable
{

  public $data = [];

  use Queueable, SerializesModels;

  /**
   * Create a new message instance.
   *
   * @return void
   */
   public function __construct(Array $formValues)
   {
     $this->data = $formValues;
   }

  /**
   * Build the message.
   *
   * @return $this
   */
  public function build(Request $request)
  {
    return $this->from("john@onelance.ch")
                ->subject("Nouveau mail de John")
                ->view('emails.sendmail');
  }
}
