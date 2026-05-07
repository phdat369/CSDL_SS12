use miniprojectss12;

create table users (
   user_id int primary key auto_increment,
   user_name varchar(50) not null unique,
   password varchar(255) not null,
   email varchar(100) unique not null,
   created_at datetime default current_timestamp
);
create table posts (
   post_id int primary key auto_increment,
   user_id int not null,
   content text not null,
   created_at datetime default current_timestamp,
   foreign key (user_id) references users(user_id) on delete cascade
);
create table comments (
   comment_id int primary key auto_increment,
   post_id int not null,
   user_id int not null,
   content text not null,
   created_at datetime default current_timestamp,
   foreign key (post_id) references posts (post_id) on delete cascade,
   foreign key (user_id) references users (user_id) on delete cascade
);
create table friends (
   user_id int not null,
   friend_id int not null,
   status varchar(20) check (status in ('pending','accepted')),
   foreign key (user_id) references users (user_id) on delete cascade,
   foreign key (friend_id) references users (user_id) on delete cascade,
   primary key (user_id,friend_id),
   check (user_id <> friend_id)
);
create table likes (
   user_id int not null,
   post_id int not null,
   foreign key (user_id) references users (user_id) on delete cascade,
   foreign key (post_id) references posts (post_id) on delete cascade,
   primary key (user_id,post_id)
);

-- Thêm dữ liệu vào bảng users
insert into users (user_name, password, email) values
('nguyenvana', 'pass123', 'vana@gmail.com'),
('tranthib', 'pass234', 'thib@gmail.com'),
('leminhc', 'pass345', 'minhc@gmail.com'),
('phamthid', 'pass456', 'thid@gmail.com'),
('hoange', 'pass567', 'e@gmail.com');
-- Thêm dữ liệu vào bảng posts
insert into posts (user_id, content) values
(1, 'Hôm nay trời đẹp quá!'),
(2, 'Đang học SQL rất thú vị'),
(3, 'Cuối tuần đi chơi thôi'),
(4, 'Mới xem một bộ phim hay'),
(5, 'Thích lập trình database');
-- Thêm dữ liệu vào bảng comments
insert into comments (post_id, user_id, content) values
(1, 2, 'Đúng vậy!'),
(1, 3, 'Thời tiết rất đẹp'),
(2, 4, 'SQL rất hữu ích'),
(3, 5, 'Đi đâu vậy?'),
(5, 1, 'Database rất quan trọng');
-- Thêm dữ liệu vào bảng friends
insert into friends (user_id, friend_id, status) values
(1, 2, 'accepted'),
(1, 3, 'pending'),
(2, 4, 'accepted'),
(3, 5, 'accepted'),
(4, 5, 'pending');
-- Thêm dữ liệu vào bảng likes
insert into likes (user_id, post_id) values
(1, 2),
(2, 1),
(3, 5),
(4, 3),
(5, 4);

create view vw_UserInfo 
as select user_id,user_name,email,created_at
from users;
select user_id,user_name,email,created_at
from vw_UserInfo;

create view vw_PostStatistics 
as select p.post_id,p.content,u.user_name,count(l.user_id) as total_like,count(c.comment_id) as total_comment
from posts p 
left join users u 
on u.user_id = p.user_id 
left join comments c 
on c.post_id = p.post_id 
left join likes l
on l.post_id = p.post_id 
group by p.post_id;
select post_id,content,user_name,total_like,total_comment
from vw_PostStatistics;

delimiter //
create procedure register_user (
   in new_user_name varchar(50),
   in new_password varchar(255),
   in new_email varchar(100),
   out massage varchar(50)
)
begin 
   if new_email in (select email
                    from users)
   then set massage = 'Email đã được sử dụng';
   else insert into users(user_name,password,email)
        values (new_user_name,new_password,new_email);
	end if;
end //
delimiter ;
call register_user('xyz','pass1234','sssc@gmail.com',@massage);
select @massage ;

delimiter // 
create procedure create_post (
   in new_user_id int,
   in new_content text,
   out new_post_id int 
)
begin
   insert into posts(user_id,content)
   values (new_user_id,new_content);
   set new_post_id = (select max(post_id)
                      from posts);
end //
delimiter ;
call create_post(1,'Hello wordl',@postid);
select @postid as new_post_id;

delimiter //
create procedure search_lits_friend (
   in s_user_id int,
   in s_limit int,
   in s_offset int
)
begin
   select u.user_name,u.email
   from users u 
   inner join friends f 
   on f.friend_id = u.user_id
   where f.user_id = s_user_id and f.status = 'accepted'
   limit s_limit
   offset s_offset;
end // 
delimiter ;
call search_lits_friend(1,5,0);

create index idx_post_created_at
on posts(created_at);

