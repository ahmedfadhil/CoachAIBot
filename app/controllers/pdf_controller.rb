class PdfController < ApplicationController
  layout 'pdfs'

  def user_plans_pdf

    @users = User.all
    @plans = User.first.plans

=begin
=end
    pdf = WickedPdf.new.pdf_from_string(render_to_string('pdfs/user_plans_pdf', layout: 'layouts/pdfs.html'))
    # save to a file
    save_path = Rails.root.join('tmp','filename.pdfs')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end



    #save
    render 'pdfs/user_plans_pdf', layout: 'pdfs'

  end




  private

  # should cause a download of the file, and no change to web screen
  def save
    pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
            template: 'pdfs/plans.pdfs.erb',
            layout: 'layouts/application.pdfs.erb'))
    send_data(pdf,
              filename: 'example.pdfs',
              type: 'application/pdfs',
              disposition: 'attachment')
  end

end
