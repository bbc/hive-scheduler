class AddReservationDetailsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :reservation_details, :blob
  end
end
