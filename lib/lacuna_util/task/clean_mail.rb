# encoding: utf-8

require 'lacuna_util/task'
require 'lacuna_util/logger'

class CleanMail < LacunaUtil::Task

    def args

    end

    def _run(args, config)
        status = Lacuna::Empire.get_status

        if status['empire']['has_new_messages'].to_i == 0
            Logger.log "No messages to delete! You're all clear!"
            return
        end

        # Array of message ids representing messages needing to be trashed.
        to_trash = []

        page = 1
        seen = 0
        tags = ['Parliament', 'Probe']

        # Isolationists are not affected by Fissures.
        tags << 'Fissure' if status['empire']['is_isolationist'].to_i > 0

        self.trash(self.get_mail_to_trash(page, seen, tags))
    end

    def get_mail_to_trash(page, seen, tags)
        to_trash = []
        while true
            Logger.log "Checking page #{page}"

            inbox = Lacuna::Inbox.view_inbox({
                :tags => tags,
                :page_number => page,
            })

            inbox['messages'].each do |message|
                seen += 1
                to_trash << message['id']
            end

            # Check if this is the last page.
            if inbox['message_count'].to_i == seen
                break
            else
                page += 1
            end
        end
        to_trash
    end

    def trash(to_trash = [])
        Logger.log "Trashing #{to_trash.size} messages... hang on tight, kid!"
        Lacuna::Inbox.trash_messages to_trash
    end
end

LacunaUtil.register_task CleanMail
