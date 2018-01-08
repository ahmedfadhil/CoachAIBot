class PdfController < ApplicationController
  layout 'pdf'

  def user_plans_pdf

    @users = User.all
    @plans = User.first.plans

=begin
=end
    pdf = WickedPdf.new.pdf_from_string(render_to_string('pdf/user_plans_pdf', layout: 'layouts/pdf.html'))
    # save to a file
    save_path = Rails.root.join('tmp','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end



    #save
    render 'pdf/user_plans_pdf', layout: 'pdf'

  end




  private

  # should cause a download of the file, and no change to web screen
  def save
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
            template: 'pdf/plans.pdf.erb',
            layout: 'layouts/application.pdf.erb'))
    send_data(pdf,
              filename: 'example.pdf',
              type: 'application/pdf',
              disposition: 'attachment')
  end

end
