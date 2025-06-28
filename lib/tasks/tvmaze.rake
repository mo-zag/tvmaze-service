# lib/tasks/tvmaze.rake
namespace :tvmaze do
    desc "Backfill TVMaze schedule with rate limiting"
    task backfill: :environment do
      dates = (0..100).map { |i| Date.today - i }
  
      dates.each_slice(20).with_index do |date_batch, batch_index|
        puts "Processing batch ##{batch_index + 1}..."
        
        date_batch.each do |date|
          puts "Ingesting #{date}..."
          begin
            TvmazeIngestor.run(date: date)
          rescue => e
            puts "Failed to ingest #{date}: #{e.message}"
          end
        end
  
        puts "Sleeping for 10 seconds to respect rate limits..."
        sleep 10
      end
    end
  end
  